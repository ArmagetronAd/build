%define name    armagetronad-dedicated
%define version 0.2.8.0
%define release 0.5.beta20050811.1mdk
%define armaversion 0.2.8.0_beta20050811

Name:           %{name}
Summary:        3d light cycle game
Version:        %{version}
Release:        %{release} 
Source:     armagetronad-%{armaversion}.tar.bz2
Source2:    armagetronadLARGE.png
Source3:    armagetronadMEDIUM.png
Source4:    armagetronadSMALL.png
URL:            http://armagetronad.sourceforge.net/

Group:          Applications/Games/Arcade
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot 
License:        GPL

%description
Armagetron Advanced is a really addicting light cycle
game reminiscent of the Disney movie TRON.  Rather than
be a clone of the Disney movie's light cycle sequence,
Armagetron Advanced brings a new type of gameplay to the
genre.

Armagetron Advanced was originally a fork of the game
Armagetron by Manual Moos, but Mr. Moos has since rejoined
development and has blessed Armagetron Advanced as the official
Armagetron.

This package is the dedicated server.

%prep 
%setup -n armagetronad-%{armaversion}

%build 
%configure2_5x --disable-glout --disable-sysinstall
%make

%install
rm -rf $RPM_BUILD_ROOT
%makeinstall

#menu
mkdir -p $RPM_BUILD_ROOT%{_menudir}
cat << EOF > $RPM_BUILD_ROOT%{_menudir}/%{name}
?package(%{name}):\
   command="%{name}"\
   icon="%{name}.png"\
    needs="text"\
    title="Armagetron Advanced Server"\
    longtitle="Armagetron Advanced Dedicated Server"\
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
%{_prefix}/share/games/%name/scripts/sysinstall install /usr
%update_menus
        
%postun
%{_prefix}/share/games/%name/scripts/sysinstall uninstall /usr
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
%{_prefix}/share/games/%name/resource/included/HexaTRON/0.4.2.xml
%{_prefix}/share/games/%name/resource/included/Your_mom/inaktek-.7.1.xml
%{_prefix}/share/games/%name/resource/included/Your_mom/repeat-.3.1.xml
%{_prefix}/share/games/%name/resource/included/map-0.1-exp.dtd
%{_prefix}/share/games/%name/resource/included/map-0.1.dtd
%{_prefix}/share/games/%name/resource/included/n-gon/40.xml
%{_prefix}/share/games/%name/resource/included/original/map-1.0.1.xml
%{_prefix}/share/games/%name/scripts/sysinstall
%{_prefix}/share/games/armagetronad-dedicated/scripts/rcd_config
%{_prefix}/share/games/armagetronad-dedicated/scripts/rcd_server
%{_prefix}/share/games/armagetronad-dedicated/scripts/rcd_startstop
%{_prefix}/share/games/armagetronad-dedicated/scripts/serverstarter

%changelog
* Thur Aug 11 2005 Dave Fancella <dave@davefancella.com> 0.2.8.0-0.5.beta20050811.mdk
- Adapted to build dedicated server.

* Mon Aug 01 2005 Dave Fancella <dave@davefancella.com> 0.2.8.0-0.beta-1.mdk
- Updated specfile for new version and build system

* Mon May 23 2005 Dave Fancella <dave@davefancella.com> 0.2.8.beta1-1mdk
- Started specfile