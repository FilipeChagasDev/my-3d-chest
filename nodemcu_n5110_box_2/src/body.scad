/*

MIT License

Copyright (c) 2020 Filipe Chagas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

$fn = 50;

// -------- SCREW NUT PARAMS ---------
screw_nut_radius = 5.5/2;
screw_nut_thickness = 2;
// ----------------------------------

//cylinder cut in half
module half_cylinder(radius, height)
{
    difference()
    {
        cylinder(height, radius, radius);
        translate([0,-radius,-1])cube([radius*2, radius*2, height+2]);
    }
}

//support for fixing the cover with screws
module screw_holder(size, holding_x, r, vertical = true, thickness = 3)
{   
    if(vertical)
    {
        rotate([-90,-90,0])
            screw_holder(size, holding_x, r, false, thickness);
    }
    else
    {
        union()
        {
            difference()
            {
                union()
                {
                    cube([size/2, size, thickness]);
                    
                    translate([size/2,size/2,0])
                        cylinder(thickness, size/2, size/2);
                }
                
                //screw nut hole
                translate([size/2,size/2,-1])cylinder($fn=6,thickness+2, screw_nut_radius, screw_nut_radius);
            }
            
            translate([0,0,screw_nut_thickness]) difference()
            {
                union()
                {
                    cube([size/2, size, thickness]);
                    
                    translate([size/2,size/2,0])
                        cylinder(thickness, size/2, size/2);
                }
                
                translate([size/2,size/2,-1])cylinder(thickness+2, r, r);
            }
            
            translate([-holding_x,0,0])
            {
                cube([holding_x, size, thickness]);
                translate([0,size/2,0]) half_cylinder(size/2, thickness);
            }
            
        }
    }    
}

//cube with rounded edges
module rounded_cube(xlen, ylen, zlen, radius)
{
    union()
    {
        translate([radius, radius, 0])
            cylinder(zlen, radius, radius);
        
        translate([xlen - radius,radius,0])
            cylinder(zlen, radius, radius);
        
        translate([radius,ylen - radius,0])
            cylinder(zlen, radius, radius);
        
        translate([xlen - radius,ylen - radius,0])
            cylinder(zlen, radius, radius);
        
        translate([radius,0,0])
            cube([xlen - 2*radius, ylen, zlen]);
        
        translate([0,radius,0])
            cube([xlen, ylen - 2*radius, zlen]);
    }
}

//hollow cube with rounded edges and opening at the top
module rounded_top_open_box(xlen, ylen, zlen, radius, screw_radius = 0, thickness = 3)
{
    screw_holder_sz = screw_radius * 6;
    screw_holder_h = 5;
    if(screw_radius > 0)
    {
        union()
        {
            rounded_top_open_box(xlen, ylen, zlen, radius, 0, thickness);
            
            // x screw
            translate([xlen/2 - screw_holder_sz/2,thickness,zlen])
                screw_holder(screw_holder_sz, screw_holder_h, screw_radius, true, thickness);
            
            // xy screw
            
            translate([xlen/2 + screw_holder_sz/2,ylen - thickness,zlen])
                rotate([0,0,180])
                //translate([-screw_holder_sz,0,0])
                screw_holder(screw_holder_sz, screw_holder_h, screw_radius, true, thickness);
        }
    }
    else
    {
        difference()
        {
            rounded_cube(xlen, ylen, zlen, radius);
            translate([thickness, thickness, thickness])
                rounded_cube(xlen - thickness*2, ylen - thickness*2, zlen + 10, radius);
        }
    }
}

//hollow cube with rounded edges and opening at the bottom
module rounded_bottom_open_box(xlen, ylen, zlen, radius, screw_radius = 0, thickness = 3)
{
    screw_holder_sz = screw_radius * 6;
    if (screw_radius > 0)
    {
        difference()
        {
            rounded_bottom_open_box(xlen, ylen, zlen, radius, 0, thickness);
            
            translate([xlen/2,-1,screw_holder_sz/2])
                rotate([0,90,90])
                    cylinder(thickness + 2, screw_radius, screw_radius);
            
            translate([xlen/2,ylen-thickness-1,screw_holder_sz/2])
                rotate([0,90,90])
                    cylinder(thickness + 2, screw_radius, screw_radius);
        }
    }
    else
    {
        difference()
        {
            rounded_cube(xlen, ylen, zlen, radius);
            translate([thickness, thickness, -thickness])
                rounded_cube(xlen - thickness*2, ylen - thickness*2, zlen, radius);
        }
    }
}

module clamp_hole(width, height, internal_width, internal_height, thickness = 3)
{
    difference()
    {
        cube([width, thickness, height]);
        
        translate([width/2 - internal_width/2, -1, 0])
            cube([internal_width, thickness+2, internal_height]);
        
    }
}

module nodemcu_box(xlen, ylen, zlen, radius, screw_radius = 0, thickness = 3)
{
    union()
    {
        difference()
        {
            rounded_top_open_box(xlen, ylen, zlen, radius, screw_radius, thickness);

            translate([xlen-0.1,ylen/2,thickness - 3.5])
                union()
                {
                    translate([1.999 -thickness,-10.7,0])
                        cube([thickness + 15,21.4,10.7]);
                        
                    translate([-thickness,0,5.35])
                        scale([1,1,0.5])
                            rotate([45,0,0]) rotate([0,90,0])
                                cylinder(2,5,15, $fn=4);
                }
                
           
        }
       
        
        
        hwoffset = 8/thickness;
        hw = 10;
        hh = 7;
        iw = hw - hw/4;
        ih = hh - hh/4;
        
        translate([xlen - hw - thickness + (hw/2-iw/2), ylen/2 + 15,thickness])
            clamp_hole(hw,hh,iw,ih,3);

        translate([thickness - (hw/2-iw/2), ylen/2 + 15,thickness])
            clamp_hole(hw + hwoffset,hh,iw + hwoffset,ih,3);
        
        translate([xlen - hw - thickness + (hw/2-iw/2), ylen/2 + 15,thickness])
            clamp_hole(hw,hh,iw,ih,3);
        
        translate([thickness - (hw/2-iw/2), ylen/2 - 18,thickness])
            clamp_hole(hw + hwoffset,hh,iw + hwoffset,ih,3);
        
        translate([xlen - hw - thickness + (hw/2-iw/2), ylen/2 - 18,thickness])
            clamp_hole(hw,hh,iw,ih,3);
        
        
        nodemcu_hole_radius = 1.25;
        translate([xlen - thickness - 2.6, ylen/2 - 11,thickness])
            cylinder(5,nodemcu_hole_radius,nodemcu_hole_radius);
            
        translate([xlen - thickness - 2.6, ylen/2 + 11,thickness])
            cylinder(5,nodemcu_hole_radius,nodemcu_hole_radius);
            
        translate([xlen - thickness - 46.8, ylen/2 - 11,thickness])
            cylinder(5,nodemcu_hole_radius,nodemcu_hole_radius);
            
        translate([xlen - thickness - 46.8, ylen/2 + 11,thickness])
            cylinder(5,nodemcu_hole_radius,nodemcu_hole_radius);
    }
}


// ------------------------------------------------------
// ---------------- MAIN PARAMETERS ---------------------
// ------------------------------------------------------

xlen = 60; //width
ylen = 60; //depth
zlen = 40; //height
radius = 5; //edge rounding radius
screw_radius = 1.6; //screw hole radius
thcknss = 3; //structure thickness

include_nodemcu = false; //set it false for printing
cut_x = false; //set it false for printing
cut_y = false; //set it false for printing

include_side_holes = true;
side_hole_radius = 2.5;
side_hole_distance_for_lid = 20;

// ------------------------------------------------------



difference()
{
    color([0.5,0.5,0.5])
        nodemcu_box(xlen, ylen, zlen, radius, screw_radius,thcknss);

        
    // ------------ SIDE HOLES -----------------
    translate([15,thcknss+1,zlen-side_hole_distance_for_lid])
        rotate([90,0,0])
            cylinder(h=thcknss+3, r=side_hole_radius, center=false); 


    translate([25,thcknss+1,zlen-side_hole_distance_for_lid])
        rotate([90,0,0])
            cylinder(h=thcknss+3, r=side_hole_radius, center=false); 


    translate([35,thcknss+1,zlen-side_hole_distance_for_lid])
        rotate([90,0,0])
            cylinder(h=thcknss+3, r=side_hole_radius, center=false); 

    translate([45,thcknss+1,zlen-side_hole_distance_for_lid])
        rotate([90,0,0])
            cylinder(h=thcknss+3, r=side_hole_radius, center=false); 
    // -----------------------------------------
    
    if (cut_x)
    {
        translate([xlen/2,-1,-50])
            cube([xlen/2+1,ylen+2,zlen+100]);
    }
    
    if (cut_y)
    {
        translate([-1,-1,-50])
            cube([xlen+2,ylen/2+2,zlen+100]);
    }
}

if(include_nodemcu)
{
    color([0.9,0.1,0.1])
        translate([60 - thcknss,17,13 + thcknss])
            rotate([90,180,90*3])
                import("../stl/nodemcu.stl");
}