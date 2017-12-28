import QtQuick 2.7

Rectangle {
    clip: true
    property int ti
    Timer {
        id: animator
        repeat: true
        interval: ti
        running:true

        property var colors: [
            [255, 255, 255],
            [255, 255, 255]
        ]
        property var color0:colors[0]
        property var color1:colors[1]

        property var newColors: null;

        property real oldprogress: 0;
        property real newProgress: 0;

        function hsvLerp(a, b, t) {
            var h1 = a[0]
            var h2 = b[0]
            var d = h2-h1
            var color = [0, 0, 0]

            if(Math.abs(d) > 180) {
                if(d > 0) h1 += 360
                else h2 += 360

                color[0] = (h1 + t * (h2 - h1));

                while(color[0]> 360) {
                    color[0] -= 360
                }
            }
            else
                color[0] = h1 + t * d;

            color[1] = a[1] + (b[1] - a[1]) * t;
            color[2] = a[2] + (b[2] - a[2]) * t;

            return color
        }

        function rgbLerp(a, b, t) {
            var color = [0, 0, 0];

            color[0] = a[0] + (b[0] - a[0]) * t;
            color[1] = a[1] + (b[1] - a[1]) * t;
            color[2] = a[2] + (b[2] - a[2]) * t;

            return color
        }

        function getColors() {
            if(oldprogress > colors.length) {
                oldprogress -= colors.length;
            }

            var offset = Math.floor(oldprogress)
            var t = (oldprogress - offset);

            var a = colors[offset];
            var b = colors[(offset + 1)% colors.length];
            var c = colors[(offset + 2)% colors.length];

            return [rgbLerp(a, b, t), rgbLerp(b, c, t)];
        }

        function setColors(col){
            colors = col;

            var c = getColors();

            newColors = [color0, color1, c[0], c[1]];

            newProgress = 0
        }

        onTriggered: {
            if(newColors) {
                newProgress+=0.1

                if(newProgress<1) {
                    color0 = rgbLerp(newColors[0], newColors[2], newProgress);
                    color1 = rgbLerp(newColors[1], newColors[3], newProgress);
                    return;
                }

                newColors = null
            }

            oldprogress += 0.02;

            var c = getColors();

            color0 = c[0];
            color1 = c[1];
        }
    }

    function setColors(col,ti) {
        this.ti = ti;
        var pal = (col !== 'undefined'? !false: false)
        animator.setColors(pal? col : [[100, 180, 100], [200, 100, 100], [150, 100, 200], [100, 200, 220]])
    }

    gradient:Gradient
    {
        GradientStop {
            id: start
            position:0
            color: Qt.rgba(animator.color0[0] / 255, animator.color0[1] / 255, animator.color0[2] / 255, 1)
        }

        GradientStop {
            id: end
            position:1
            color: Qt.rgba(animator.color1[0] / 255, animator.color1[1] / 255, animator.color1[2] / 255, 1)
        }
    }
}
