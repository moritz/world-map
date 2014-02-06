use v6;

my %countries = <ad ae af ag ai al am ao ar as at au aw az ba bb bd be bf bg bh bi bj bl bm bn bo br bs bt bw by bz ca cd cf cg ch ci ck cl cm cn co cr cu cv cw cy cz de dj dk dm do dz ec ee eg eh er es et fi fj fk fm fo fr ga gb gd ge gg gh gi gl gm gn gq gr gt gu gw gy hn hr ht hu id ie il im in iq ir is it je jm jo jp ke kg kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mf mg mh mk ml mm mn mp mr ms mt mu mv mw mx my mz na nc ne nf ng ni nl no np nr nu nz om pa pe pf pg ph pk pl pm pn pr ps pt pw py qa ro rs ru rw sa sb sc sd se sg sh si sk sl sm sn so sr ss st sv sx sy sz tc td tg th tj tk tl tm tn to tr tt tv tw tz ua ug us uy uz va vc ve vg vi vn vu wf ws ye za zm zw> Z=> 1;

class RGB {
    has int $.r;
    has int $.g;
    has int $.b;

    multi method Str(RGB:D:) {
        sprintf '#%02x%02x%02x', $.r, $.g, $.b;
    }
}

constant yellow = RGB.new(r => 255, g => 255, b => 0  );
constant red    = RGB.new(r => 255, g => 0,   b => 0  );
constant blue   = RGB.new(r => 0,   g => 0,   b => 255);

sub fill-map-raw($css = '', :$template-filename = 'word-map.svg.template') {
    my $template-fh = open $template-filename;
    for $template-fh.lines {
        if defined .index('CSSPLACEHOLDER') {
            say $css;
        }
        else {
            .say;
        }
    }
}

sub css-for($country, $color) {
    Q:s[.$country path { fill: $color }];
    #:: (unconfuse the syntax hilighter)
}

sub color-linear-interpolate($value,
    :$range = 0..1,
    RGB :$lower-color = red,
    RGB :$upper-color = yellow,
) {
    unless $value ~~ $range {
        die X::OutOfRange.new(
            :what('input value to gen-color-scale'),
            :got($value),
            :expected($range),
        );
    }
    my $a = ($value - $range.min) / ($range.max - $range.min);
    my $b = 1 - $a;
    RGB.new(
        :r(($lower-color.r * $a + $upper-color.r * $b).Int),
        :g(($lower-color.g * $a + $upper-color.g * $b).Int),
        :b(($lower-color.b * $a + $upper-color.b * $b).Int),
    );
}

my %data = (
    fr  => 22,
    de  => 18,
    us  => 5,
    cn  => 2,
    uk  => 30,
    br  => 15,
    be  => 1,
);

map-linear(%data);

sub map-linear(%data) {
#    my @illegal = %data.keys.grep: {!%countries{$_}};
#    die "The following keys in your dataset are not known country codes: @illegal.join(', ')" if @illegal;
    my $range   = %data.values.minmax;
    my %colors  = %data.map: {; .key => color-linear-interpolate(.value, :$range ) };
    my $css = join "\n", %colors.kv.flat.map: &css-for;
    fill-map-raw($css);
}

