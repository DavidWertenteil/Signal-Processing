function plotAccelerationBuffer(x,y,z,t)
g = 9.81;
persistent h
if(isempty(h) || ~ishandle(h(1)))
    figure
    h = plot(t', g*[x',y',z'],'LineWidth',1.5);
    xlim([0 t(end)])
    ylim([-2*g 2*g])
    xlabel('Time offset (s)')
    ylabel('Acceleration (m \cdot s^{-2})')
    legend({'a_x','a_y','a_z'})
    grid on   
end
h(1).YData = g*x'; 
h(2).YData = g*y'; 
h(3).YData = g*z';
