# currency-flags

This package outputs two CSS files (minified and unminified) with classes for currency codes using base64 background images inlined.

## How to use

**1. Install**

`npm install --save https://github.com/transferwise/currency-flags.git`

**2. Add CSS to page**

**3. Use**

```html
<div class="currency-flag currency-flag-usd"></div>
```

<img src="http://i.imgur.com/Fdd5VLp.png">

The `currency-flag` selector has a default `display` of `inline-block`, size of `24x16` and a `background-size` of `cover`.
`currency-flag-sm`, `currency-flag-lg` and `currency-flag-xl` modifiers are available.

## How to add flags

1. Clone repo
1. Run `npm install`
1. Add correctly sized (`48x32`) `png` files to `src/flags`
1. Run `npm run build`
1. Commit to a new branch, include css files changed by build process
1. Open a pull request
1. Draft a release on GitHub with the same version as specified in `package.json`
