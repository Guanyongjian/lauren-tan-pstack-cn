# benny

benny 给你两个用于 slack issue report 的 cursor automation。一个对每份 report 做 triage。另一个复现已确认的 bug，并可能准备一个小规模的修复草稿。

这个目录里的 file 是休眠状态的 setup 与 automation 源料。它们不会以 slash skill 的形式出现。

## set it up

1. 让 cursor 指向 [`FOR_AGENTS.md`](./FOR_AGENTS.md)，并指定目标 repository。
2. 让 setup 把这整个目录合并到目标里的 `.cursor/automations/benny/`。它必须保留目标端独有的 file，并对冲突做 review，而不是覆盖本地改动。
3. 让 setup 在目标 repository 的 `.cursor/settings.json` 里为共享依赖启用 pstack：

```json
{
	"plugins": {
		"pstack": { "enabled": true }
	}
}
```

4. 把 user 自有的配置留在被复制的 pack 之外，例如放在 `.cursor/benny/`。参照 [`configuration.example.yaml`](./templates/configuration.example.yaml) 和 [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md) 去改写。
5. 在启用任何一个 automation 之前，先 commit `.cursor/settings.json`、`.cursor/automations/benny/`，以及任何不含密钥的配置。
6. 在各自的 editor 里 review 每一个新建的 automation 草稿，或更新已有的 automation。然后发一份无害的测试 report，并核实每一处 source-channel 发帖都留在原来的 thread 里。