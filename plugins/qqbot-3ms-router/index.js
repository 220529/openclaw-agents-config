import fs from "node:fs";
import path from "node:path";

const FIXED_COMMANDS = new Set([
	"看上游更新",
	"同步更新",
	"拉取上游仓库并部署",
	"拉取主项目",
	"拉取主项目并部署",
	"看分支",
	"列分支",
	"部署前检查",
	"执行部署",
	"口令",
	"列出所有口令"
]);

const BRANCH_TEMPLATE = /^切分支\s+\S(?:.*\S)?$/u;
const DEFAULT_TIMEOUT_MS = 240000;
const DEFAULT_ACCOUNT_IDS = ["default"];

function isFixed3msCommand(content) {
	return FIXED_COMMANDS.has(content) || BRANCH_TEMPLATE.test(content);
}

function normalizePluginConfig(pluginConfig) {
	const raw = pluginConfig && typeof pluginConfig === "object" ? pluginConfig : {};
	const accountIds = Array.isArray(raw.accountIds) ? raw.accountIds.map((value) => String(value).trim()).filter(Boolean) : DEFAULT_ACCOUNT_IDS;
	return {
		accountIds: accountIds.length > 0 ? accountIds : DEFAULT_ACCOUNT_IDS,
		intentScriptPath: typeof raw.intentScriptPath === "string" && raw.intentScriptPath.trim() ? raw.intentScriptPath.trim() : "",
		timeoutMs: Number.isFinite(raw.timeoutMs) && raw.timeoutMs >= 1000 ? Number(raw.timeoutMs) : DEFAULT_TIMEOUT_MS,
		requireSystemPromptMarker: raw.requireSystemPromptMarker !== false
	};
}

function resolveWorkspacePath() {
	return process.env.OPENCLAW_WORKSPACE?.trim() || path.join(process.env.HOME || "/root", ".openclaw", "workspace");
}

function resolveIntentScriptPath(pluginConfig) {
	if (pluginConfig.intentScriptPath) return pluginConfig.intentScriptPath;
	return path.join(resolveWorkspacePath(), "bin", "qq-3ms-intent");
}

function resolveQqbotAccountConfig(cfg, accountId) {
	const qqbot = cfg?.channels?.qqbot ?? {};
	if (!accountId || accountId === "default") return qqbot;
	return qqbot?.accounts?.[accountId] ?? {};
}

function has3msMarker(cfg, accountId) {
	const accountConfig = resolveQqbotAccountConfig(cfg, accountId);
	const prompt = [
		accountConfig?.systemPrompt,
		cfg?.channels?.qqbot?.systemPrompt
	].filter((value) => typeof value === "string" && value.trim()).join("\n");
	return prompt.includes("$3ms-workspace-ops") || prompt.includes("qq-3ms-intent") || prompt.includes("3ms 工作区");
}

function normalizeAllowFromEntry(entry) {
	return String(entry).trim().replace(/^qqbot:/i, "").toUpperCase();
}

function isSenderAuthorized(cfg, accountId, senderId) {
	const allowFrom = resolveQqbotAccountConfig(cfg, accountId)?.allowFrom;
	if (!Array.isArray(allowFrom) || allowFrom.length === 0) return true;
	const normalized = allowFrom.map(normalizeAllowFromEntry).filter(Boolean);
	if (normalized.includes("*")) return true;
	if (!senderId) return false;
	return normalized.includes(normalizeAllowFromEntry(senderId));
}

function parseReplyLines(rawText) {
	const orderedDetails = [];
	const plainDetails = [];
	const plainLines = [];
	for (const rawLine of String(rawText || "").split(/\r?\n/)) {
		const line = rawLine.trim();
		if (!line) continue;
		const match = /^([A-Z0-9_]+)=(.*)$/.exec(line);
		if (!match) {
			plainLines.push(line);
			continue;
		}
		const [, key, rawValue] = match;
		const value = rawValue.trim();
		if (!value) continue;
		if (key === "QQ_RESULT") {
			plainLines.unshift(value);
			continue;
		}
		if (key === "QQ_DETAIL") {
			plainDetails.push(value);
			continue;
		}
		const detailIndex = /^QQ_DETAIL_(\d+)$/.exec(key);
		if (detailIndex) {
			orderedDetails[Number(detailIndex[1])] = value;
		}
	}
	const numbered = [];
	for (let i = 0; i < orderedDetails.length; i++) {
		if (orderedDetails[i]) numbered.push(orderedDetails[i]);
	}
	return [...plainLines, ...numbered, ...plainDetails].slice(0, 12);
}

function formatFailureReply(stdout, stderr) {
	const parsed = parseReplyLines(`${stdout || ""}\n${stderr || ""}`);
	if (parsed.length > 0) return parsed.join("\n");
	for (const rawLine of `${stdout || ""}\n${stderr || ""}`.split(/\r?\n/)) {
		const line = rawLine.trim();
		if (!line || /^[A-Z0-9_]+=/.test(line)) continue;
		return `这次执行失败了。\n${line.slice(0, 280)}`;
	}
	return "这次执行失败了，脚本没有返回可展示结果。";
}

async function run3msIntent(api, intentScriptPath, content, timeoutMs, logger, accountId) {
	if (!fs.existsSync(intentScriptPath)) return "3ms 执行入口不存在，请先检查工作区脚本配置。";
	logger?.info?.(`qqbot-3ms-router: hard-route matched for account=${accountId} content=${content}`);
	const result = await api.runtime.system.runCommandWithTimeout([intentScriptPath, content], {
		timeoutMs,
		cwd: resolveWorkspacePath(),
		env: {
			...process.env,
			QQBOT_ACCOUNT_ID: accountId
		}
	});
	if (result.termination === "timeout" || result.killed) return "这次执行超时了，请稍后再试。";
	if (result.code !== 0) return formatFailureReply(result.stdout, result.stderr);
	const replyLines = parseReplyLines(result.stdout);
	return replyLines.length > 0 ? replyLines.join("\n") : "已执行，但脚本没有返回可展示结果。";
}

export default {
	id: "qqbot-3ms-router",
	name: "QQBot 3ms Router",
	description: "Hard-route fixed 3ms QQ commands before agent dispatch",
	version: "2026.4.13",
	configSchema: {
		type: "object",
		additionalProperties: false,
		properties: {
			accountIds: {
				type: "array",
				items: { type: "string" },
				default: DEFAULT_ACCOUNT_IDS
			},
			intentScriptPath: {
				type: "string"
			},
			timeoutMs: {
				type: "number",
				minimum: 1000,
				default: DEFAULT_TIMEOUT_MS
			},
			requireSystemPromptMarker: {
				type: "boolean",
				default: true
			}
		}
	},
	register(api) {
		const pluginConfig = normalizePluginConfig(api.pluginConfig);
		const intentScriptPath = resolveIntentScriptPath(pluginConfig);
		api.on("before_dispatch", async (event, ctx) => {
			if (event.channel !== "qqbot") return;
			const content = String(event.content ?? "").trim();
			if (!content || !isFixed3msCommand(content)) return;
			const accountId = ctx.accountId?.trim() || "default";
			if (!pluginConfig.accountIds.includes(accountId)) return;
			if (pluginConfig.requireSystemPromptMarker && !has3msMarker(api.config, accountId)) return;
			if (!isSenderAuthorized(api.config, accountId, ctx.senderId)) return;
			const text = await run3msIntent(api, intentScriptPath, content, pluginConfig.timeoutMs, api.logger, accountId);
			return {
				handled: true,
				text
			};
		}, { priority: 1000 });
	}
};
