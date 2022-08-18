function [ para ] = setPara( varargin )
%SSM Summary of this function goes here
% ƽ��SPRģ�ͣ��ο�����Principles of nanoparticle imaging using surface plasmons doi:10.1088/1367-2630/17/1/013041
% SetPara: ����ģ�͵ĸ��ֱ������ɸı���Ƕ����������������ݶ������ı䣬
% ���ÿ�θı䶨��������Ҫˢ����������Ϊ��Ч�ʿ�����ȡһ����ˢ�£������з��ա�
% 
% ������
para.A=1;%ϵ�����볡������ǿ���й�
para.dm=47e-9;%��������
para.e0=8.854187817E-12;%��ս�糣��F/m
para.mu0=4*pi*1E-7;%��մŵ���H/m
para.n1=1.514;%����������
para.n2=0.1355+1i*3.88;%��Ĥ��680nm�µ�������%0.14737+1i*4.7414;%��Ĥ��780nm�µ�������
para.n3=1.333;%��������������
para.thetaInc=deg2rad(69.336);%��Ų������69.336
para.phiInc=deg2rad(0);%���䷽λ��
para.wl=670e-9;%��Ų�����[m]
para.rp=50e-9;%�����뾶[m]
para.np=0.135+3.88*1i;%����������
para.siz=[501,501];%ģ�������С
para.deltaDistance=1e-8;%ÿ���ص����[m]
para.center=[251,251];%��������
para.nLimit=5;%�������
para.deltah=200e-9;%�������Ĥ�߶�
% �������޸�

while length(varargin)>=2
    prop =varargin{1};
    val=varargin{2};
    varargin=varargin(3:end);
    eval(['para.' prop '=val;']);     
end

% ������
para.h=para.rp+para.deltah;%������������
para.z=-para.dm;%��Ұ���Ĥ�±������
para.k0=2*pi/para.wl;%��ʸ��С
para.e3=para.n3^2;%������糣��
para.e1=para.n1^2;
para.omega=2*pi*3e8/para.wl;%ԲƵ��
% [X,Y]=meshgrid(1:para.siz(1),1:para.siz(2));
[X,Y]=meshgrid(1:para.siz(2),1:para.siz(1));
para.r=sqrt((para.deltaDistance*sqrt((X-para.center(2)).^2+(Y-para.center(1)).^2)).^2+para.h.^2);%ͼ�ϵ��������r������
para.theta=acos(para.h./para.r);%�춥��[0,pi/2)%asin((X-para.center(2))./para.r*para.deltaDistance)-pi/2;%ͼ�ϵ��������theta������[0,2pi)
%para.phi=0;%ͼ�ϵ��������theta������
para.phi=zeros(para.siz(1),para.siz(2));
for iy=1:para.siz(1)
    for ix=1:para.siz(2)
        dx=ix-para.center(2);
        dy=iy-para.center(1);
        if dx>=0 && dy>=0
            para.phi(iy,ix)=atan(dy/dx);
        end
        if dx<0 && dy>=0
            para.phi(iy,ix)=pi-atan(-dy/dx);
        end
        if dx<0 && dy<0
            para.phi(iy,ix)=pi+atan(dy/dx);
        end
        if dx>=0 && dy<0
            para.phi(iy,ix)=2*pi-atan(-dy/dx);
        end%��λ��phi=0-2pi
    end
end

para.kx=para.n1*abs(para.k0)*sin(para.thetaInc)*cos(para.phiInc);
para.ky=para.n1*abs(para.k0)*sin(para.thetaInc)*sin(para.phiInc);

% para.k3z=-para.n3*abs(para.k0)*sqrt(1-(para.n1/para.n3*sin(para.thetaInc)));
% para.k2z=para.k3z.*para.n2./para.n3;
% para.k1z=para.k3z.*para.n1./para.n3;
% % ����������ʸz����ԭ���ˣ��������ĸ���
para.k3z=-para.n3*abs(para.k0)*sqrt(1-(para.n1/para.n3*sin(para.thetaInc))^2);
para.k2z=para.n2*abs(para.k0)*sqrt(1-(para.n1/para.n2*sin(para.thetaInc))^2);
para.k1z=para.n1*abs(para.k0)*cos(para.thetaInc);

para.kxy=sqrt(para.kx^2+para.ky^2);
para.N=para.np/para.n3;
para.rho=para.kxy*para.rp;

para.B=para.A.*(exp((abs(para.k3z)-abs(para.k1z)).*para.dm./2)./(2.*abs(para.k2z)./(para.n2.*para.n2))).*(exp(-abs(para.k2z).*para.dm).*((abs(para.k2z)./(para.n2.*para.n2))-(abs(para.k1z)./(para.n1.*para.n1)))+exp(abs(para.k2z).*para.dm).*((abs(para.k1z)./(para.n1.*para.n1))+(abs(para.k2z)./(para.n2.*para.n2))));%ϵ��B
para.Ii=abs(para.B).*abs(para.B).*para.e3.*para.e3.*pi.*sinh(2.*abs(para.k3z).*para.rp).*exp(abs(para.k3z).*para.h)./(abs(para.k3z).*para.rp);%SPP�����䵽���׿����ϵ�ǿ��

para.E0x=para.B.*exp(abs(para.k3z).*para.z)./(para.omega.*para.e3.*para.e0).*1i.*para.k3z.*...
    exp(1i*para.deltaDistance*(para.kx*(X-para.center(2))+para.ky*(Y-para.center(1)))); % ������ʽ1
for n=0:para.nLimit
    [para.ANR(n+1),para.ANTHETA(n+1)]=an(n,para.N,para.rho);
end

% para.E0r=ones(para.siz);
% �˾伫�֣����������¸���
para.E0r = -i*abs(para.k3z).*sin(para.theta).*cos(para.phi) ...
    - i*para.ky*abs(para.k3z)/para.kx.*sin(para.theta).*sin(para.phi)...
    + (para.kx + (para.ky)^2/para.kx)*cos(theta);
para.E0theta = -i*abs(para.k3z).*cos(para.theta).*cos(para.phi) ...
    - i*para.ky*abs(para.k3z)/para.kx.*cos(para.theta).*sin(para.phi)...
    + (para.kx + (para.ky)^2/para.kx)*sin(theta);
para.E0phi = i*abs(para.k3z)*sin(para.phi) - i*para.ky*abs(para.k3z)/para.kx*cos(para.phi);

end

