%define name    armagetronad 
%define version 0.2.8.0
%define release 0.5.beta20050812.1mdk
%define armaversion 0.2.8.0_beta20050812

Name:           %{name}
Summary:        3d light cycle game
Version:        %{version}
Release:        %{release} 
Source:     armagetronad-%{armaversion}.tar.bz2
Source2:    %{name}LARGE.png
Source3:    %{name}MEDIUM.png
Source4:    %{name}SMALL.png
URL:            http://armagetronad.sourceforge.net/

Group:          Applications/Games/Arcade
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot 
License:        GPL

%description
In this game you ride a lightcycle; that is a sort of motorbike that
cannot be stopped and leaves a wall behind it. The main goal of the game
is to make your opponents' lightcycles crash into a wall while avoiding
the same fate.
The focus of the game lies on the multiplayer mode, but it provides
challenging AI opponents for a quick training match.

%prep 
%setup -n armagetronad-%{armaversion}

%build 
%configure2_5x --disable-sysinstall
%make

%install
rm -rf $RPM_BUILD_ROOT
%makeinstall

#menu
mkdir -p $RPM_BUILD_ROOT%{_menudir}
cat << EOF > $RPM_BUILD_ROOT%{_menudir}/%{name}
?package(%{name}):\
   command="%{name} -s '%u'"\
   icon="%{name}.png"\
    needs="x11"\
    title="Armagetron Advanced"\
    longtitle="Armagetron Advanced Light Cycle Game"\
    section="Applications/Games/Arcade"
EOF

#icons
mkdir -p $RPM_BUILD_ROOT/%_liconsdir
cat %SOURCE2 > $RPM_BUILD_ROOT/%_liconsdir/%name.png
mkdir -p $RPM_BUILD_ROOT/%_iconsdir
cat %SOURCE3 > $RPM_BUILD_ROOT/%_iconsdir/%name.png
mkdir -p $RPM_BUILD_ROOT/%_miconsdir
cat %SOURCE4 > $RPM_BUILD_ROOT/%_miconsdir/%name.png

%post
%update_menus
        
%postun
%clean_menus

%clean 
rm -rf $RPM_BUILD_ROOT 

%files 
%defattr(-,root,root,0755) 
%doc README COPYING ChangeLog
%{_bindir}/*
#%{_mandir}/man1/%name.1.*
%{_menudir}/%name
%{_datadir}/doc
#%{_gamesbindir}/%name
#%{_gamesdatadir}
%{_liconsdir}/%name.png
%{_iconsdir}/%name.png
%{_miconsdir}/%name.png
%{_sysconfdir}/games/%name/aiplayers.cfg
%{_sysconfdir}/games/%name/default.cfg
%{_sysconfdir}/games/%name/master.srv
%{_sysconfdir}/games/%name/rc.config
%{_sysconfdir}/games/%name/settings.cfg
%{_sysconfdir}/games/%name/settings_dedicated.cfg
%{_prefix}/share/games/%name/language/american.txt
%{_prefix}/share/games/%name/language/british.txt
%{_prefix}/share/games/%name/language/deutsch.txt
%{_prefix}/share/games/%name/language/english_base.txt
%{_prefix}/share/games/%name/language/french.txt
%{_prefix}/share/games/%name/language/languages.txt
%{_prefix}/share/games/%name/language/languages.txt.in
%{_prefix}/share/games/%name/language/spanish.txt
%{_prefix}/share/games/%name/language/update.py
%{_prefix}/share/games/%name/models/cycle_body.mod
%{_prefix}/share/games/%name/models/cycle_front.mod
%{_prefix}/share/games/%name/models/cycle_rear.mod
%{_prefix}/share/games/%name/resource/included/HexaTRON/0.4.2.xml
%{_prefix}/share/games/%name/resource/included/Your_mom/inaktek-.7.1.xml
%{_prefix}/share/games/%name/resource/included/Your_mom/repeat-.3.1.xml
%{_prefix}/share/games/%name/resource/included/map-0.1-exp.dtd
%{_prefix}/share/games/%name/resource/included/map-0.1.dtd
%{_prefix}/share/games/%name/resource/included/n-gon/40.xml
%{_prefix}/share/games/%name/resource/included/original/map-1.0.1.xml
%{_prefix}/share/games/%name/scripts/sysinstall
%{_prefix}/share/games/%name/sound/cyclrun.wav
%{_prefix}/share/games/%name/sound/expl.wav
%{_prefix}/share/games/%name/textures/KGN_logo.png
%{_prefix}/share/games/%name/textures/cycle_body.png
%{_prefix}/share/games/%name/textures/cycle_wheel.png
%{_prefix}/share/games/%name/textures/dir_wall.png
%{_prefix}/share/games/%name/textures/floor.png
%{_prefix}/share/games/%name/textures/floor_a.png
%{_prefix}/share/games/%name/textures/floor_b.png
%{_prefix}/share/games/%name/textures/font.png
%{_prefix}/share/games/%name/textures/font_extra.png
%{_prefix}/share/games/%name/textures/font_s.png
%{_prefix}/share/games/%name/textures/icon.png
%{_prefix}/share/games/%name/textures/rim_wall.png
%{_prefix}/share/games/%name/textures/shadow.png
%{_prefix}/share/games/%name/textures/sky.png
%{_prefix}/share/games/%name/textures/title.jpg
%{_prefix}/share/games/%name/textures/wrap.png

%changelog

* Mon Aug 01 2005 Dave Fancella <dave@davefancella.com> 0.2.8.0-0.beta-1.mdk
- Updated specfile for new version and build system

* Mon May 23 2005 Dave Fancella <dave@davefancella.com> 0.2.8.beta1-1mdk
- Started specfile