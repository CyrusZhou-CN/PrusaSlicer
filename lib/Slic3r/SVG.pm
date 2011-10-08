package Slic3r::SVG;
use strict;
use warnings;

use SVG;

use constant X => 0;
use constant Y => 1;

sub factor {
    return $Slic3r::resolution * 10;
}

sub svg {
    my ($print) = @_;
    $print ||= Slic3r::Print->new(x_length => 200 / $Slic3r::resolution, y_length => 200 / $Slic3r::resolution);
    my $svg = SVG->new(width => $print->max_length * factor(), height => $print->max_length * factor());
    
    my $marker_end = $svg->marker(
        id => "endArrow",
        viewBox => "0 0 10 10",
        refX => "1",
        refY => "5",
        markerUnits => "strokeWidth",
        orient => "auto",
        markerWidth => "10",
        markerHeight => "8",
    );
    $marker_end->polyline(
        points => "0,0 10,5 0,10 1,5",
        fill => "darkblue",
    );
    
    return $svg;
}

sub output {
    my ($print, $filename, %things) = @_;
    
    my $svg = svg($print);
    
    foreach my $type (qw(polygons polylines white_polygons red_polygons red_polylines)) {
        if ($things{$type}) {
            my $method = $type =~ /polygons/ ? 'polygon' : 'polyline';
            my $g = $svg->group(
                style => {
                    'stroke-width' => 2,
                    'stroke' => $type =~ /red_/ ? 'red' : 'black',
                    'fill' => ($type !~ /polygons/ ? 'none' : ($type =~ /red_/ ? 'red' : 'grey')),
                },
            );
            foreach my $polygon (@{$things{$type}}) {
                my $path = $svg->get_path(
                    'x' => [ map($_->[X] * factor(), @$polygon) ],
                    'y' => [ map($_->[Y] * factor(), @$polygon) ],
                    -type => 'polygon',
                );
                $g->$method(
                    %$path,
                    'marker-end' => "url(#endArrow)",
                );
            }
        }
    }
    
    foreach my $type (qw(points red_points)) {
        if ($things{$type}) {
            my ($colour, $r) = $type eq 'points' ? ('black', 2) : ('red', 3);
            my $g = $svg->group(
                style => {
                    'stroke-width' => 2,
                    'stroke' => $colour,
                    'fill' => $colour,
                },
            );
            foreach my $point (@{$things{$type}}) {
                $g->circle(
                    cx      => $point->[X] * factor(),
                    cy      => $point->[Y] * factor(),
                    r       => $r,
                );
            }
        }
    }
    
    foreach my $type (qw(lines red_lines green_lines)) {
        if ($things{$type}) {
            my ($colour) = $type =~ /^(red|green)_/;
            my $g = $svg->group(
                style => {
                    'stroke-width' => 2,
                },
            );
            foreach my $line (@{$things{$type}}) {
                $g->line(
                    x1 => $line->[0][X] * factor(),
                    y1 => $line->[0][Y] * factor(),
                    x2 => $line->[1][X] * factor(),
                    y2 => $line->[1][Y] * factor(),
                    style => {
                        'stroke' => $colour || 'black',
                    },
                    'marker-end' => "url(#endArrow)",
                );
            }
        }
    }
    
    write_svg($svg, $filename);
}

sub output_points {
    my ($print, $filename, $points, $red_points) = @_;
    return output($print, $filename, points => $points, red_points => $red_points);
}

sub output_polygons {
    my ($print, $filename, $polygons) = @_;
    return output($print, $filename, polygons => $polygons);
}

sub output_polylines {
    my ($print, $filename, $polylines) = @_;
    return output($print, $filename, polylines => $polylines);
}

sub output_lines {
    my ($print, $filename, $lines) = @_;
    return output($print, $filename, lines => $lines);
}

sub write_svg {
    my ($svg, $filename) = @_;
    
    open my $fh, '>', $filename;
    print $fh $svg->xmlify;
    close $fh;
    printf "SVG written to %s\n", $filename;
}

1;
