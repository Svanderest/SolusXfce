echo "Installing updates"
sudo eopkg upgrade
echo "Installing build tools"
sudo eopkg install -c system.devel
echo "Installing dependencies"
sudo eopkg install wget xtrans libxmu-devel util-macros-devel gtk-doc-devel vala libgtk-2-devel libgtk-3-devel libstartup-notification-devel perl-uri libwnck-devel libcanberra-devel libnotify-devel libxklavier-devel colord-devel libinput-devel xorg-driver-input-libinput-devel 
echo "Creating sources directory"
mkdir sources
cd sources
for file in $(grep -v '^#' ../Files)
do
  conf="--prefix=/usr --sysconfdir=/etc --enable-gtk-doc"
  name=$(echo $file | sed 's/\(.*\)-/\1 /' | awk '{print $2}')
  major=$(echo $file | sed 's|-| |' | sed 's|\.| |g' | awk '{print $2}')
  minor=$(echo $file | sed 's|-| |' | sed 's|\.| |g' | awk '{print $3}')
  echo "Installing $name $major $minor"
  directory=${file%.tar.bz2}  
  case $file in    
    iceauth-1.0.8.tar.bz2 )
      wget https://www.x.org/pub/individual/app/$file
      conf="$conf --localstatedir=/var"
    ;;
    *)
      wget http://archive.xfce.org/src/xfce/$name/$major.$minor/$file
    ;;
  esac
  
  case $file in
    xfce4-session-4.14.2.tar.bz2 )
      conf="$conf --disable-legacy-sm"
    ::
  esac
  tar xvf $file
  pushd $directory
  ./configure $conf
  make
  sudo make install
  popd  
  rm -rf $directory
done
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/xfwm4/budgie-wm/' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
