# Daily News Style

Use this file when the user asks to match the referenced `AI Daily News` style.

## Core Shape

The style is a compact information feed:

1. `AI Daily News` title
2. short note block
3. date or weekly range
4. `AI行业动态`
5. one image slot
6. numbered industry news items
7. `今天值得关注的产品`
8. `Product Hunt Top 5`
9. `GitHub Trending Top 5`

## Top Note

Use a short note only when producing a complete recurring digest:

```markdown
☀️ 说明
- 全文由 Codex 生成，更新时间：<time>，周期：<window>
- 新闻源：<source count or source families>
```

If the user only wants a one-off article draft, omit the operational note unless requested.

## News Item Format

Each news item is:

```markdown
1. <公司/产品 + 动作 + 结果>

<来源名 + 事件事实 + 意义判断 + 不确定性标注（如有）> [更多](<url>)
```

Good item characteristics:

- headline carries the whole point
- paragraph starts from source or actor
- one paragraph only
- no sub-bullets
- enough context to understand why it matters
- `据称` or `被曝` for leaks
- `官方称` for primary-source claims

## Product Tables

Product Hunt:

```markdown
🚀 Product Hunt Top 5

| 排名 | 产品 | 介绍 |
|---:|---|---|
| 1 | <name> | <short Chinese description> |
```

GitHub Trending:

```markdown
🔥 GitHub Trending Top 5

| 排名 | 项目 | 星级 | 介绍 |
|---:|---|---:|---|
| 1 | <owner/repo> | 🌟+<delta> | <short Chinese description> |
```

## Weekly Variant

For weekly digests, replace the date heading with:

```markdown
一周重点新闻 |（MM.DD-MM.DD）
```

Then keep the same `AI行业动态` and product-section order.

## Style Guardrails

- Keep the whole digest scannable.
- Do not add title-option lists in daily mode.
- Do not add a long editorial intro.
- Do not add a separate "我怎么看" under every item.
- Put uncertainty inside the item paragraph.
- Prefer concise Chinese explanations over translated English jargon.
