*=$C000
sinus
.byte 128.5 + 127 * sin(range(256) * rad(360.0/256))
