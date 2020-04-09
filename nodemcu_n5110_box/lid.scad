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
                screw_holder(screw_holder_sz, screw_holder_h, screw_radius);
            
            // xy screw
            translate([xlen/2 - screw_holder_sz/2,ylen - 2*thickness,zlen])
                screw_holder(screw_holder_sz, screw_holder_h, screw_radius);
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

module n5110()
{
    /*
    color([0.7,0.7,0.7])
        import("n5110.stl");
    */
    
    color([0.0,0.0,0.7])
        translate([-0.15,0.8,0])
            cube([40.5,34.5,10], center=true);
    
    translate([17.2,-20.3,0])
        cylinder(10,1.6,1.6);
    
    translate([-17.35,-20.3,0])
        cylinder(10,1.6,1.6);
    
    translate([17.1,20.7,0])
        cylinder(10,1.6,1.6);
    
    translate([-17.4,20.7,0])
        cylinder(10,1.6,1.6);
}

module lid(xlen, ylen, zlen, radius, screw_radius, thickness = 3)
{
    difference()
    {
        rounded_bottom_open_box(xlen, ylen, zlen, radius, screw_radius);
        translate([xlen/2,ylen/2,zlen-4]) n5110();
    }
}

// ------------------------------------------------------
// ---------------- MAIN PARAMETERS ---------------------
// ------------------------------------------------------


xlen = 60; //width
ylen = 60; //depth
zlen = 20; //height
radius = 5; //edge rounding radius
thcknss = 3; //structure thickness
screw_radius = 1.5; //screw holes radius
show_display = true; //set it false for printing

// -----------------------------------------------------

color([0.8,0.8,0.8])
    lid(xlen, ylen, zlen, radius, screw_radius,thcknss);

if(show_display)
{
    color([1,0,0])
        translate([xlen/2,xlen/2,zlen-5])
            import("n5110.stl");
}