<?php

$settings['file_public_path'] = 'files';
$settings['file_private_path'] = 'files/private';
$config['locale.settings']['translation']['path'] = 'files/translations';

$settings['config_sync_directory'] = '../config';

if (defined('PANTHEON_ENVIRONMENT') && !empty(\Drupal::hasService('cache.backend.redis'))) {
  // Include the Redis services.yml file.
  // Adjust the path if you installed to a contrib or other subdirectory.
  $settings['container_yamls'][] = 'modules/redis/example.services.yml';

  //phpredis is built into the Pantheon application container.
  $settings['redis.connection']['interface'] = 'PhpRedis';
  // These are dynamic variables handled by Pantheon.
  $settings['redis.connection']['host']      = $_ENV['CACHE_HOST'];
  $settings['redis.connection']['port']      = $_ENV['CACHE_PORT'];
  $settings['redis.connection']['password']  = $_ENV['CACHE_PASSWORD'];

  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['cache_prefix']['default'] = 'pantheon-redis';

  // Set Redis to not get the cache_form (no performance difference).
  $settings['cache']['bins']['form']      = 'cache.backend.database';
}

if (
  isset($_ENV['PANTHEON_ENVIRONMENT'])
  && !in_array($_ENV['PANTHEON_ENVIRONMENT'], ['test', 'live'])
  // If we're on Patheon and developing
) {
  $settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
  $settings['cache']['bins']['render'] = 'cache.backend.null';
  $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
  $settings['cache']['bins']['page'] = 'cache.backend.null';
}
