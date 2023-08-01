#!/bin/bash



##phpinfo##
cat > /alidata/www/default/index.html << END
<html><body><h1>It works!</h1></body></html>
END

cat > /alidata/www/default/info.php << END
<?php
phpinfo();
?>
END

##copy-php_version##
\cp ./res/switch_php_version.sh  /root/
\cp -r /root/switch_php_version.sh /bin/switch

