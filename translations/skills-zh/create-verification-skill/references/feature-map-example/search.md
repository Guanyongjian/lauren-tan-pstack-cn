# 搜索笔记

搜索让用户能按标题或正文查找笔记、查看匹配项，并区分无匹配和搜索不可用。

## Sub-features

- `search-open` 从每个受支持的浏览器入口打开搜索。
- `search-match` 返回标题和正文匹配项，不修改笔记数据。
- `search-open-result` 在笔记编辑器中打开结果。
- `search-empty` 为无匹配查询显示完整的空状态。
- `search-clear` 清除查询并恢复最近笔记视图。
- `search-cli` 从终端返回相同的匹配笔记。

## How to get to it (user POV)

- 在浏览器工具栏选择 `Search` 按钮。
- 焦点不在可编辑字段时，在浏览器中按 `/`。
- 在终端运行 `notes search <query>`。

## Driving it with control-notes

Preconditions:

- Notes 在 `http://127.0.0.1:4173` 正常运行。
- 一次性数据目录包含标题为 `Quarterly plan`、正文为 `Draft budget` 的笔记。
- `control-notes doctor` 报告预期的 URL 和数据目录。

- **工具栏入口。** 选择 `Search` 按钮。运行 `control-notes browser click --role button --name "Search"`。出现名为 `Search notes` 的对话框，焦点位于搜索框。
- **键盘入口。** 关闭对话框、聚焦页面并按 `/`。运行 `control-notes browser press --key "/"`。出现同一个对话框，页面不会插入斜杠。
- **标题匹配。** 输入 `quarterly`。运行 `control-notes browser fill --role searchbox --name "Search notes" --value "quarterly"`。`Search results` 列表包含 `Quarterly plan`，不包含 `Grocery list`。
- **正文匹配。** 把查询替换为 `budget`。运行 `control-notes browser fill --role searchbox --name "Search notes" --value "budget"`。结果 `Quarterly plan` 仍然可见，并显示正文匹配摘录。
- **打开结果。** 选择 `Quarterly plan`。运行 `control-notes browser click --role link --name "Quarterly plan"`。对话框关闭，编辑器标题显示 `Quarterly plan`。
- **空状态。** 重新打开搜索并输入 `volcano`。运行 `control-notes browser fill --role searchbox --name "Search notes" --value "volcano"`。搜索完成后出现名为 `No matching notes` 的状态。
- **清除查询。** 选择 `Clear search`。运行 `control-notes browser click --role button --name "Clear search"`。搜索框为空，`Recent notes` 区域取代结果列表。
- **CLI 匹配。** 从终端搜索。运行 `control-notes cli -- notes search "quarterly" --format json`。退出码为 `0`，标准输出包含一个标题为 `Quarterly plan` 的对象。
- **CLI 无匹配。** 搜索不存在的值。运行 `control-notes cli -- notes search "volcano" --format json`。退出码为 `0`，标准输出为 `[]`。
- **证据。** 采集有结果的状态。运行 `control-notes browser snapshot --aria --path artifacts/search/results.aria.txt` 和 `control-notes browser screenshot --path artifacts/search/results.png`。两份证据都能识别 Notes、查询内容和 `Quarterly plan`。

## Gotchas

- 编辑器或搜索框有焦点时按 `/` 会输入文本，而不是打开搜索。
- 结果在短暂防抖后更新。等待结果列表或空状态，不要固定休眠。
- 除非用户启用 `Include archived`，否则不包括已归档笔记。
- CLI 默认输出便于阅读的格式。稳定断言使用 `--format json`。
- 打开结果会改变浏览器状态。验证另一个查询之前，重新打开搜索。
