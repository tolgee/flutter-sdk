# Tolgee Flutter SDK 🐁

Flutter packages for the [Tolgee](https://tolgee.io) localization platform.

| Package | What it does |
|---|---|
| [`tolgee`](packages/tolgee) | Translations from the Tolgee API in dev builds, from the CDN or bundled files in release builds |
| [`tolgee_in_context`](packages/tolgee_in_context) | Edit translations right in the running app, in dev builds |

Both packages are released together with the same version.

The [example app](packages/tolgee/example) uses both.

## Contributing

Contributions are welcome! Run the checks in each package folder:

```bash
cd packages/tolgee && flutter analyze && flutter test
cd packages/tolgee_in_context && flutter analyze && flutter test
```

----
🧀
