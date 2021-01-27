# Setup
## Mit `npm`
Wir brauchen: 
- elm compiler: `npm install --global elm`
- `elm-format`: `npm install --global elm-format`
- `elm-live`: `npm install --global elm-live`

### Bei Rechteproblemen:
```
sudo npm install --global elm elm-format elm-live --allow-root --unsafe-perm=true
```

## Alternative
Der elm compiler lässt sich auch [ohne npm installieren](https://guide.elm-lang.org/install/elm.html).

## IDEs

Für die meisten IDEs gibt es auch elm plugins, z.B. Jetbrains, vscode, ...

### Jetbrains/IntelliJ
- elm plugin installieren
- auto-discover verwenden, bei `elm-format` 'format on save' aktivieren (keybinding geht nicht)