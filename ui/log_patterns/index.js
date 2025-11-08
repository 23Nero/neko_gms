.pragma library

var patterns = [
    {
        regex: /^(\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}\.\d+)\s+(\d+)\s+(\d+)\s+([VDIWEF])\s+([^\s:]+):\s*(.*)$/,
        transform: function(matches) {
            return {
                time: matches[1] + " " + matches[2],
                pid: matches[3],
                tid: matches[4],
                level: matches[5],
                tag: matches[6],
                message: matches[7]
            };
        }
    }
];

function all() {
    return patterns;
}

