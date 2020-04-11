/*
Author: Filipe Chagas
Email: filipe.ferraz0@gmail.com
GitHub: github.com/filipechagasdev
*/
$fn = 30;

module solid(w,h,linear_scale=1)
{
    linear_extrude(h,twist=90*6,slices=100,scale = linear_scale)
        translate([5,0,0])
            circle(w/2);
}

module bottom(solid_w,solid_h, bottom_h)
{
    intersection()
    {
        cube([solid_w*2, solid_w*2, bottom_h*2], center=true);
        solid(solid_w,solid_h);
    }
}

module torus(circle_r, torus_r, circle_scale=[1,1])
{
    rotate_extrude()
        translate([torus_r,0,0])
            scale(circle_scale)
                circle(circle_r);
}

module handle(body_w, body_h)
{
        scale([1,1,1.2])
            rotate([90,0,0])
                torus(5,body_h/4,[0.5,1]);
}

module mug(w,h)
{
    bottom_h = (h*7)/70;
    bottom_hole_scale = 0.7;
    top_hole_scale = 1.3;
    top_thickness = (w-(w*bottom_hole_scale*top_hole_scale))/2;
    
    union()
    {
        difference()
        {
            solid(w,h);
            scale([bottom_hole_scale,bottom_hole_scale,1])
                solid(w,h,top_hole_scale);
        }
        
        difference()
        {
            translate([w/2+5,0,h/2])
                handle(w,h);
            
            scale([bottom_hole_scale,bottom_hole_scale,1])
                solid(w,h,top_hole_scale);
        }
        
        bottom(w,h,bottom_h);
        
        translate([-5,0,70])
            torus(top_thickness, w/2 - top_thickness);
    }
}

// ----------------------------------------
// ---------- MAIN PARAMETERS -------------
// ----------------------------------------
width = 65;
height = 70;
// ----------------------------------------

color([0.5,0.5,0.5])
    mug(65,70);
