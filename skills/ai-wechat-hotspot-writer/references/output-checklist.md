# Output Checklist

Run this checklist before final delivery.

## Source Quality

- Every core hotspot has at least one source.
- Major factual claims have primary or credible media support.
- Rumors and leaks are labeled as unconfirmed.
- Source names and links are preserved when available.
- Social heat is not presented as fact.

## Time Window

- The exact start and end dates are stated.
- Items outside the requested window are marked as background or excluded.
- Weekly and multi-week outputs do not pretend to be daily freshness.

## Article Quality

- The article has a clear thesis.
- The opening explains why the roundup matters now.
- Each hotspot explains "what happened" and "why it matters."
- Product radar items are not mixed with core industry analysis unless they deserve it.
- The ending gives a grounded forward-looking view.

## Daily News Style

- The output starts with `AI Daily News` or the requested title.
- The note block states generation/update cadence and source scope when relevant.
- The date heading is explicit.
- `AI行业动态` appears before product sections.
- A daily cover image placeholder or prompt is placed after `AI行业动态` when image prompts are requested.
- Numbered news items use `1. <headline>` followed by one compact paragraph.
- Each news paragraph is roughly 110-180 Chinese characters unless the topic requires more context.
- Source links are embedded as `更多` or an equivalent source label.
- `今天值得关注的产品` contains `Product Hunt Top 5` and `GitHub Trending Top 5` tables when data is available.
- The digest does not turn into a long essay unless `wechat_longform` is requested.

## WeChat Fit

- Paragraphs are short enough for mobile reading.
- Headings are direct and scannable.
- Jargon is explained.
- The article avoids exaggerated slogans.
- The piece has enough opinion to be worth reading, but does not overclaim.

## Image Prompt Quality

- Prompts include article thesis, layout, style, text rules, and constraints.
- GPT Image 2 and Nano Banana 2 prompts are separated.
- Long-image prompts use 9:16 or another explicit vertical format.
- Prompts avoid fake logos and unsupported numbers.
- Each visual panel maps to a verified hotspot.

## Save And Reply

- If files were saved, include relative or absolute paths.
- If saving failed, still return the core article and prompts.
- In chat, summarize the top 3 writing directions rather than pasting the whole article unless requested.
