// generated file

var carouselItemVertex = "
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
uniform mediump float radius;
uniform mediump float angle;
uniform mediump float spread;
uniform mediump float pointerAngle;
uniform mediump float maxAngle;

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    highp vec4 shift = vec4(1.0, 1.0, 0.0, 0.0);
    shift.x = cos(angle) * radius;
    shift.y = sin(angle) * radius;

    mediump float d = abs(angle - pointerAngle);
    if (d > maxAngle / 2.0) {
        d = maxAngle - d;
    }
    mediump float scaleFactor = spread * (1.0 - sqrt(d / maxAngle));
    highp mat4 scale = qt_Matrix * mat4(scaleFactor, 0.0, 0.0, 0.0
                                        , 0.0, scaleFactor, 0.0, 0.0
                                        , 0.0, 0.0, 1.0, 0.0
                                        , 0.0, 0.0, 0.0, 1.0);

    gl_Position = scale * (qt_Vertex + shift);
}
"

var carouselItemFragment = "
varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform sampler2D selectedSource;
uniform mediump float spread;
uniform lowp float qt_Opacity;
uniform bool isSelected;
void main() {
    float opac = qt_Opacity * spread;
    mediump vec4 t1 = texture2D(source, qt_TexCoord0);
    if (isSelected) {
        mediump vec4 t2 = texture2D(selectedSource, qt_TexCoord0);
        gl_FragColor = mix(t1, t2, 0.5);
    } else {
        gl_FragColor = t1 * opac;
    }
}
"
