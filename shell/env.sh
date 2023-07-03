#!/usr/bin/env bash

update-safe-node-and-npm() {
    SHIM_DIR="$HOME/.node-safe/bin"

    if ! create-shim-dir-or-fail "$SHIM_DIR"; then
        return
    fi

    VANILLA_NODE=$(which node)
    NODE_SAFE=$(which node-safe)

    if [ "$VANILLA_NODE" = "$NODE_SAFE" ]; then
        echo 'node and npm are already linked to -safe versions'
        return
    fi

    NODE_SHIM="$SHIM_DIR/node"

cat >"$NODE_SHIM" <<EOF
#!/usr/bin/env bash
export NODE_SAFE_IMPLICIT_LAUNCH=true
export NODE_SAFE_DIR=\$(dirname "\$0")
exec "$VANILLA_NODE" "$NODE_SAFE" "\$@"
EOF

    chmod +x "$NODE_SHIM"

    NPM_SAFE=$(which npm-safe)
    NPM_SHIM="$SHIM_DIR/npm"

cat >"$NPM_SHIM" <<EOF
#!/usr/bin/env bash
export NODE_SAFE_IMPLICIT_LAUNCH=true
export NODE_SAFE_DIR=\$(dirname "\$0")
exec "$VANILLA_NODE" "$NPM_SAFE" "\$@"
EOF

    chmod +x "$NPM_SHIM"
    
    export PATH="$SHIM_DIR:$PATH"
}

create-shim-dir-or-fail() {
    if [ -e "$1" ]; then
        if [ ! -d "$1" ]; then
            echo "node-safe shell integration: \"$1\" already exists but is not a directory"
            return 1
        fi

        return 0
    fi

    mkdir "$1"
    return 0
}

update-safe-node-and-npm
