#   --------GRAPH BASE---------
using CairoMakie
fig = Figure(size = (1100, 600))

ax_trajectory = Axis(fig[1:2, 1], 
                title = "Particle accelarator in Spiral Path",
                xlabel = "X Position(meters)",
                ylabel = "Y Position(meters)",
                aspect = DataAspect()
                    )
ax_speed = Axis(fig[1, 2], 
                title = "Velocity Profile (Staircase Accelaration)",
                xlabel = "Time (seconds)",
                ylabel = "speed (m/s)"
                )
ax_mass = Axis(fig[2, 2], 
               title = "Einstien's Relativistic Mass Gain",
               xlabel = "Time (seconds)",
               ylabel = "Mass (kg)"
               )   


# --------Defining the Constants--------

function simulate_cyclotron()
 c = 3.0e8             #speed of light (m/s) = 3 * 10^8
 q = 1.6e-19           #charge on a particle (coulombs)= 1.6 * 10^-19
 B = 4.1               #magnetic field strength (tesla)
 m0 = 1.67e-27         #mass of proton (kgs)
 V_gap = 8.0e6         #voltage across the center gap (volts)= 1.5 * 10^5

dt = 5.0e-11
total_steps = 8000

t_hist = zeros(total_steps)
x_hist = zeros(total_steps)
y_hist = zeros(total_steps)
v_hist = zeros(total_steps)
m_hist = zeros(total_steps)

#Initial states of particle

x, y = 0.01, 0.0
vx, vy = 0.0, 1.0e6
m = m0 

# -------Loop Conditioning-------
    for i = 1:total_steps
    v = sqrt(vx^2 + vy^2)

        if v < c 
            
            global m = m0 / sqrt(1.0 - (v^2 / c^2) )        
        else   
            global m = m0 / 0.00001 #Capping it to prevent zero error
        end

        if (x_hist[max(1, i-1)] < 0 && x >= 0) || (x_hist[max(1, i-1)] > 0 && x <= 0)

# the [ΔE = q* V_gap] & [K.E = 1/2 mv^2]  and k.E(new)= k.E(old) + energy Gain

        v_new_sq = v^2 + 2 * q * V_gap / m
            if v_new_sq < c^2
                v_new = sqrt(v_new_sq)
                vx = (vx / v) * v_new
                vy = (vy / v) * v_new
                v = v_new 
            end
        end

#lorentz magnetic force for bending calculations
# F = q * (v x B)

    ax_force = (q * B * vy) / m
    ay_force = (-q * B * vx) / m

    vx += ax_force * dt 
    vy += ay_force * dt
    x += vx * dt
    y += vy * dt

    t_hist[i] = i * dt
    x_hist[i] = x
    y_hist[i] = y
    v_hist[i] = v
    m_hist[i] = m 

    end

# -------Data Plotting-------

# Trajectory
    lines!(ax_trajectory, x_hist, y_hist, color = :crimson)
#  speed
    lines!(ax_speed, t_hist, v_hist, color = :darkblue)
# Relativistic Mass
    lines!(ax_mass, t_hist, m_hist, color = :darkgreen)
end
simulate_cyclotron()
# Lets GOO!
fig