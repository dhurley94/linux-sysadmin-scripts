# Unfinished
import os
import os.path

wpLoc = []
wpInstalls = 0

for root, dirs, files in os.walk('/home/', followlinks=True):
        if 'virtfs' not in root and 'public_html' in root and 'wp-config.php' in files:
                wpInstalls += 1
                print "Found remnants of Wordpress"
                wpLoc.append(root)

print "%s Wordpress Installations were found." % wpInstalls

for i in wpLoc:
        print i
#       if 'DISABLE_WP_CRON' in i.join('/wp-config.php'):
#               print "%s has wp-cron disabled!" % i
