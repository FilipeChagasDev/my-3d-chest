module star(w,h,d)
{
    resize([w,h])
    translate([-1,-1])
        polygon([
                    [0+d,0+d],
                    [-0.5,1],
                    [0+d,2-d],
                    [1,2.5],
                    [2-d,2-d],
                    [2.5,1],
                    [2-d,0+d],
                    [1,-0.5]
                ]);
}

module solid()
{
        linear_extrude(70,twist=90,slices=5)
            star(70,70,0.4);
}

module bottom()
{
    difference()
    {
        solid();
        
        translate([-50,-50,5])
            cube([100,100,100]);
    }
}

module handle()
{
    rotate_extrude(angle=360)
        translate([20,0,0])
            scale([0.8,1.3])
                circle(5);
}

module cup()
{
    union()
    {
        difference()
        {
            solid();
            
            scale([0.9,0.9,1])
                solid();
        }

        difference()
        {
                
            translate([3.5,37,40])
                rotate([0,90,0])
                    handle();
            
            scale([0.9,0.9,1])
                solid();
        }
        
        bottom(); 
    }
}

color([0.5,0.5,0.5])
    cup();