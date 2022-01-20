<?php

passthru("drush eval 'passthru(\"sed '/fp_theme/d' ../.gitignore > ../.gitignore.tmp && mv ../.gitignore.tmp ../.gitignore\");'");

passthru("rm -rf ../scripts");