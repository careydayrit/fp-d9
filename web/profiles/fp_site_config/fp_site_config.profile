<?php
use Drupal\node\Entity\Node;
use Drupal\user\Entity\User;

/**
 * @file
 * Enables site configuration for a fp_site_config site installation.
 */

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function fp_site_config_form_install_configure_form_alter(&$form) {
  $form['site_information']['site_name']['#default_value'] = 'FivePaths Site';
  $form['admin_account']['account_name']['#default_value'] = 'fpadmin';
  $form['admin_account']['account_mail']['#default_value'] = 'admin@fivepaths.com';
}


function fp_site_config_install_tasks_alter(&$tasks, $install_state) {
  $tasks['fp_site_config_install_configuration'] = [
    'display_name' => 'Installing Configuration',
    'type' => 'batch'
  ];
}

function fp_site_config_install_configuration() {
  $modules = [
    'fp_site_config_content_types',
    'fp_site_config_field_storage',
    'fp_site_config_fields',
    'fp_site_config_display',
    'fp_site_config_theme_settings',
  ];

  $batch = [
    'title' => 'Installing Configuration',
    'operations' => array_map(function ($module) {
      return [
        'fp_site_config_install_configuration_module',
        [$module],
      ];
    }, $modules),
    'finished' => 'fp_site_config_install_finished',
  ];

  $batch['operations'][] = ['fp_site_config_post_install', [$modules]];

  return $batch;
}

function fp_site_config_install_configuration_module($module, array &$context = []) {
  \Drupal::service('module_installer')->install([$module]);
  $context['message'] = "Installed {$module}";
}

function fp_site_config_post_install($modules_to_uninstall, &$context = []) {
  \Drupal::configFactory()
    ->getEditable('system.theme')
    ->set('default', 'fp_theme')
    ->set('admin', 'seven')
    ->save();

  $user = User::load(1);
  $user->addRole('root');
  $user->removeRole('administrator');
  $user->save();

  $node = Node::create(['type' => 'landing_page']);
  $node->langcode = 'en';
  $node->uid = 1;
  $node->promote = 0;
  $node->sticky = 0;
  $node->title = 'Home Page';
  $node->save();

  $nid = $node->id();

  \Drupal::configFactory()
    ->getEditable('system.site')
    ->set('page.front', "/node/{$nid}")
    ->save();

  \Drupal::service('module_installer')->uninstall($modules_to_uninstall, true);

  drupal_flush_all_caches();
  
  $context['message'] = 'Ran post install tasks';
}


function fp_site_config_install_finished() {
  shell_exec('drush config-export -y');
  shell_exec('drush cr');
}
