function T=AveragePeriod(time,ref)
    aux=ref<0;
    for i=1:length(time)
        if i==1
            v=aux(i);
            j=1;
            taux(j)=time(i);
        else
            if aux(i)~=v
                v=aux(i);
                j=j+1;
                taux(j)=time(i);
            end
        end
    end

    Average=0;
    for i=1:length(taux)
        if i+2<=length(taux)
            T1=taux(i+2)-taux(i);         
            Average=Average*(i-1)/i + T1/i;
        end
    end
    T=Average;
end