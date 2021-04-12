CREATE TABLE particle_types (
  particle_type_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NULL,
  description TEXT NULL,
  PRIMARY KEY(particle_type_id)
)
TYPE=InnoDB;

CREATE TABLE projects (
  project_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NULL,
  description TEXT NULL,
  datadir VARCHAR(255) NULL,
  PRIMARY KEY(project_id)
)
TYPE=InnoDB;

CREATE TABLE microscopes (
  microscope_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NULL,
  description TEXT NULL,
  voltage INTEGER UNSIGNED NULL,
  Cs TINYINT UNSIGNED NULL,
  PRIMARY KEY(microscope_id)
)
TYPE=InnoDB;

CREATE TABLE particle_groups (
  partgroup_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  description TEXT NULL,
  date DATETIME NOT NULL,
  radius SMALLINT UNSIGNED NOT NULL,
  name VARCHAR(100) NULL,
  PRIMARY KEY(partgroup_id)
)
TYPE=InnoDB;

CREATE TABLE reference_imgs (
  reference_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  filename VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  size_x MEDIUMINT UNSIGNED NOT NULL,
  size_y MEDIUMINT UNSIGNED NOT NULL,
  PRIMARY KEY(reference_id)
)
TYPE=InnoDB;

CREATE TABLE experiment_types (
  experiment_type_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NULL,
  PRIMARY KEY(experiment_type_id)
)
TYPE=InnoDB;

CREATE TABLE symmetry (
  symmetry_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  filename VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY(symmetry_id)
)
TYPE=InnoDB;

CREATE TABLE masks (
  mask_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  filename VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  date DATETIME NOT NULL,
  size_x MEDIUMINT UNSIGNED NOT NULL,
  size_y MEDIUMINT UNSIGNED NOT NULL,
  PRIMARY KEY(mask_id)
)
TYPE=InnoDB;

CREATE TABLE filters (
  filter_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY(filter_id)
)
TYPE=InnoDB;

CREATE TABLE norm_methods (
  norm_method_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  masks_mask_id INTEGER UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  method VARCHAR(20) NOT NULL,
  PRIMARY KEY(norm_method_id),
  INDEX norm_methods_FKIndex1(masks_mask_id),
  FOREIGN KEY(masks_mask_id)
    REFERENCES masks(mask_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE experiment (
  experiment_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  experiment_types_experiment_type_id INTEGER UNSIGNED NOT NULL,
  name VARCHAR(200) NULL,
  description TEXT NULL,
  date DATETIME NULL,
  PRIMARY KEY(experiment_id),
  INDEX experiment_FKIndex1(experiment_types_experiment_type_id),
  FOREIGN KEY(experiment_types_experiment_type_id)
    REFERENCES experiment_types(experiment_type_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE mtfs (
  mtf_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  projects_project_id INTEGER UNSIGNED NOT NULL,
  name VARCHAR(100) NULL,
  filename VARCHAR(255) NULL,
  description TEXT NULL,
  PRIMARY KEY(mtf_id),
  INDEX mtfs_FKIndex1(projects_project_id),
  FOREIGN KEY(projects_project_id)
    REFERENCES projects(project_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE reference_imgs_has_projects (
  reference_imgs_reference_id INTEGER UNSIGNED NOT NULL,
  projects_project_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(reference_imgs_reference_id, projects_project_id),
  INDEX reference_imgs_has_projects_FKIndex1(reference_imgs_reference_id),
  INDEX reference_imgs_has_projects_FKIndex2(projects_project_id),
  FOREIGN KEY(reference_imgs_reference_id)
    REFERENCES reference_imgs(reference_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(projects_project_id)
    REFERENCES projects(project_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE masks_has_projects (
  masks_mask_id INTEGER UNSIGNED NOT NULL,
  projects_project_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(masks_mask_id, projects_project_id),
  INDEX masks_has_projects_FKIndex1(masks_mask_id),
  INDEX masks_has_projects_FKIndex2(projects_project_id),
  FOREIGN KEY(masks_mask_id)
    REFERENCES masks(mask_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(projects_project_id)
    REFERENCES projects(project_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE results (
  result_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  experiment_types_experiment_type_id INTEGER UNSIGNED NOT NULL,
  experiment_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(result_id),
  INDEX results_FKIndex1(experiment_id),
  INDEX results_FKIndex2(experiment_types_experiment_type_id),
  FOREIGN KEY(experiment_id)
    REFERENCES experiment(experiment_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(experiment_types_experiment_type_id)
    REFERENCES experiment_types(experiment_type_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE particle_groups_has_projects (
  particle_groups_partgroup_id INTEGER UNSIGNED NOT NULL,
  projects_project_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(particle_groups_partgroup_id, projects_project_id),
  INDEX particle_groups_has_projects_FKIndex1(particle_groups_partgroup_id),
  INDEX particle_groups_has_projects_FKIndex2(projects_project_id),
  FOREIGN KEY(particle_groups_partgroup_id)
    REFERENCES particle_groups(partgroup_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(projects_project_id)
    REFERENCES projects(project_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE micrograph_groups (
  micrographgroup_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  mtfs_mtf_id INTEGER UNSIGNED NULL,
  microscopes_microscope_id INTEGER UNSIGNED NOT NULL,
  name VARCHAR(255) NULL,
  description TEXT NULL,
  date DATETIME NULL,
  PRIMARY KEY(micrographgroup_id),
  INDEX micrograph_groups_FKIndex1(microscopes_microscope_id),
  INDEX micrograph_groups_FKIndex2(mtfs_mtf_id),
  FOREIGN KEY(microscopes_microscope_id)
    REFERENCES microscopes(microscope_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(mtfs_mtf_id)
    REFERENCES mtfs(mtf_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE particle_types_has_micrograph_groups (
  particle_types_particle_type_id INTEGER UNSIGNED NOT NULL,
  micrograph_groups_micrographgroup_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(particle_types_particle_type_id, micrograph_groups_micrographgroup_id),
  INDEX particle_types_has_micrograph_groups_FKIndex1(particle_types_particle_type_id),
  INDEX particle_types_has_micrograph_groups_FKIndex2(micrograph_groups_micrographgroup_id),
  FOREIGN KEY(particle_types_particle_type_id)
    REFERENCES particle_types(particle_type_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(micrograph_groups_micrographgroup_id)
    REFERENCES micrograph_groups(micrographgroup_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE micrographs (
  micrograph_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  micrograph_groups_micrographgroup_id INTEGER UNSIGNED NOT NULL,
  filename VARCHAR(255) NOT NULL,
  Dz_nominal FLOAT NOT NULL,
  dose FLOAT NOT NULL,
  stagepos_x FLOAT NOT NULL,
  stagepos_y FLOAT NOT NULL,
  stagepos_z FLOAT NOT NULL,
  objectpixelsize FLOAT NOT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY(micrograph_id),
  INDEX micrographs_FKIndex1(micrograph_groups_micrographgroup_id),
  FOREIGN KEY(micrograph_groups_micrographgroup_id)
    REFERENCES micrograph_groups(micrographgroup_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE results_has_experiment (
  results_result_id INTEGER UNSIGNED NOT NULL,
  experiment_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(results_result_id, experiment_id),
  INDEX results_has_experiment_FKIndex1(results_result_id),
  INDEX results_has_experiment_FKIndex2(experiment_id),
  FOREIGN KEY(results_result_id)
    REFERENCES results(result_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(experiment_id)
    REFERENCES experiment(experiment_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE micrograph_groups_has_projects (
  micrograph_groups_micrographgroup_id INTEGER UNSIGNED NOT NULL,
  projects_project_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(micrograph_groups_micrographgroup_id, projects_project_id),
  INDEX micrograph_groups_has_projects_FKIndex1(micrograph_groups_micrographgroup_id),
  INDEX micrograph_groups_has_projects_FKIndex2(projects_project_id),
  FOREIGN KEY(micrograph_groups_micrographgroup_id)
    REFERENCES micrograph_groups(micrographgroup_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(projects_project_id)
    REFERENCES projects(project_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE res_imageseriessort (
  res_imageseriessort_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  results_result_id INTEGER UNSIGNED NOT NULL,
  micrograph_groups_micrographgroup_id INTEGER UNSIGNED NOT NULL,
  micrographs_micrograph_id INTEGER UNSIGNED NOT NULL,
  goodbad BOOL NULL,
  PRIMARY KEY(res_imageseriessort_id, results_result_id),
  INDEX res_imageseriessort_FKIndex1(results_result_id),
  INDEX res_imageseriessort_FKIndex2(micrographs_micrograph_id),
  INDEX res_imageseriessort_FKIndex3(micrograph_groups_micrographgroup_id),
  FOREIGN KEY(results_result_id)
    REFERENCES results(result_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(micrographs_micrograph_id)
    REFERENCES micrographs(micrograph_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(micrograph_groups_micrographgroup_id)
    REFERENCES micrograph_groups(micrographgroup_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE particles (
  particle_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  micrographs_micrograph_id INTEGER UNSIGNED NOT NULL,
  pos_x INTEGER UNSIGNED NULL,
  pos_y INTEGER UNSIGNED NULL,
  PRIMARY KEY(particle_id),
  INDEX particles_FKIndex2(micrographs_micrograph_id),
  FOREIGN KEY(micrographs_micrograph_id)
    REFERENCES micrographs(micrograph_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
)
TYPE=InnoDB;

CREATE TABLE particles_has_particle_groups (
  particles_particle_id INTEGER UNSIGNED NOT NULL,
  particle_groups_partgroup_id INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(particles_particle_id, particle_groups_partgroup_id),
  INDEX particles_has_particle_groups_FKIndex1(particles_particle_id),
  INDEX particles_has_particle_groups_FKIndex2(particle_groups_partgroup_id),
  FOREIGN KEY(particles_particle_id)
    REFERENCES particles(particle_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  FOREIGN KEY(particle_groups_partgroup_id)
    REFERENCES particle_groups(partgroup_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
)
TYPE=InnoDB;


