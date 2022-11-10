To use this repository:

```
brew tap dingobits/dingobits
```

To stop using this repository:

```
brew untap dingobits/dingobits
```

To install from this repository:

```
brew install dingobits/dingobits/x265
```

I build bottles for convenience. In principle, you shouldn’t trust binaries from strangers, but I trust myself. To build from source:

```
brew install -s dingobits/dingobits/x265
```

To use this repository with existing formulae, it’s easier to edit  `homebrew/core`:

```
# brew edit ffmpeg
depends_on "dingobits/dingobits/x265"
```
