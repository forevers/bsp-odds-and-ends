# devtool

- general regex search
    ```
    devtool search <recipe name, ...>
    ```

- extract source for existing recipe, setup git repository, apply patches ...
    ```
    devtool modify <recipe name>
    ```

- build workspace recipe
    ```
    devtool build <recipe name>
    ```

- after commits to workspace repo, create/add patches and place in project recipe
    ```
    devtool update-recipe <recipe name>
    devtool update-recipe --append <destination layer path> <recipe name>
    ```

- update-recipe + reset
    ```
    devtool finish <recipe name>
    ```

- upgrade workspace to newer version
    ```
    devtool upgrade <recipe name>
    ```

- devtool status
    ```
    devtool status
    ```

- remove workspace recipe
    ```
    devtool reset <recipe name>
    ```
