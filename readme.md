# darren's emacs configuration

## install
```shell
$ git clone <git remote url> .emacs.d
```

## Profile (User Preference)
This configuration uses `setting/profile.el` for user-specific preferences and optional module activation. This file is ignored by Git, allowing you to keep local configurations without affecting the main repository.

### Setup
Create a directory named `setting` and a file named `profile.el` inside it:

```shell
$ mkdir setting
$ touch setting/profile.el
```

### Usage
In `profile.el`, you can load specific language modules or override settings. For example, to enable Clojure, Python, and TypeScript support:

```elisp
;;; -*- lexical-binding: t; -*-

(load "_clj.el")
(load "_py.el")
(load "_ts.el")
(load "_js.el")
(load "_vterm.el")
```

All available modules are located in the `mod/` subdirectories. Since these directories are already added to the `load-path`, you only need to provide the filename.
