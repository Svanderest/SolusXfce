echo "Installing updates"
sudo eopkg upgrade
echo "Installing build tools"
sudo eopkg install -c system.devel
echo "Installing dependencies"
sudo eopkg {wget}
echo "Creating sources directory"
mkdir sources
cd sources
for file in $(grep -v '^#' ../Files)
do
  conf="--prefix=/usr --sysconfdir=/etc"
  name=$(echo $file | sed 's/\(.*\)-/\1 /' | awk '{print $2}')
  major=$(echo $file | sed 's|-| |' | sed 's|\.| |g' | awk '{print $2}')
  minor=$(echo $file | sed 's|-| |' | sed 's|\.| |g' | awk '{print $3}')
  directory ${file%.tar.bz2}  
  case $file in
    libICE-1.0.10.tar.bz2 )
      wget https://www.x.org/pub/individual/lib/$file
      conf="$conf --localstatedir=/var --disable-static --docdir=/usr/share/doc/$directory ICE_LIBS=-lpthread"
    ;;
    iceauth-1.0.8.tar.bz2 )
      wget https://www.x.org/pub/individual/app/$file
      conf="$conf --localstatedir=/var --disable-static"
    ;;
    *)
      wget http://archive.xfce.org/src/xfce/$name/$major.$minor/$file
  esac
  
  case $file in
    xfce4-session-4.14.2.tar.bz2)
      conf="$conf --disable-legacy-sm"
    ::
  esac
  tar xvf $file
  pushd $directory
  ./configure $conf
  make
  sudo make install
  popd  
done
mkidr -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
cp /etc/xdg/xfce4/xfconf/xfce-perchannel/xfce4-session.xml .config/xfce4/xfconf/xfce-perchannel-xml/
