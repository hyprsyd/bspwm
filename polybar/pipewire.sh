#!/bin/bash

VOLUME_ICONS=("" "")
MUTED_ICON=""
MUTED_COLOR="%{F#6b6b6b}"
VOLUME=2

switchsink() {
    direction="$1"

    id="$(pactl list sinks short | cut -f 2)"
    current_sink="$(pactl get-default-sink)"
    first_sink=$(echo "$id" | sed -n '1p')
    last_sink=$(echo "$id" | sed -n '$p')

    if [ "$direction" = "next" ]; then

        if [ "$current_sink" = "$last_sink" ]; then
            pactl set-default-sink "$first_sink"
        else
                pactl set-default-sink "$last_sink"
        fi

    elif [ "$direction" = "previous" ]; then

        if [ "$current_sink" = "$first_sink" ]; then
            pactl set-default-sink "$last_sink"
        else
                pactl set-default-sink "$first_sink"
        fi

    fi
}

output() {
    DEFAULT_SINK_ID=$(pactl list sinks short | cut -f 1 | head -1)
    VOLUME=$(pactl  get-sink-volume `pactl  get-default-sink`|head -1| cut -d '/' -f 2)
    DEFAULT_SINK=$(pactl get-default-sink | cut -d '.' -f 4)
    IS_MUTED=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Mute/ s/Mute: \(yes\)/\1/p")

    if [ "${IS_MUTED}" != "" ]; then
        echo "${MUTED_COLOR}${MUTED_ICON} ${DEFAULT_SINK}"
    else

        echo "${VOLUME} | ${DEFAULT_SINK}"
    fi

}
action=$1
if [ "${action}" == "volume-up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +$VOLUME%
    canberra-gtk-play -i audio-volume-change -d "changeVolume"
elif [ "${action}" == "volume-down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -$VOLUME%
    canberra-gtk-play -i audio-volume-change -d "changeVolume"
elif [ "${action}" == "toggle-mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
elif [ "${action}" == "next-sink" ]; then
    switchsink "next"
elif [ "${action}" == "previous-sink" ]; then
    switchsink "previous"
fi

if [ -n "$action" ]; then exit 0; fi

pactl subscribe 2>/dev/null | {
    while :; do
        {
            output
        }
done
}

