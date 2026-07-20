#!/usr/bin/env bash

rofi -show drun \
    -p "Apps:" \
    -i \
    -theme-str '
    entry {
        text-color: #ffffff;
        placeholder: "Search Applications...";
    }

    mainbox {
        children: [inputbar, listview, message];
    }

    message {
        enabled: true;
        content: "⚙";
        horizontal-align: 0.5;
        padding: 10px;
    }'
