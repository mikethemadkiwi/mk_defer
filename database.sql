CREATE TABLE `_mkAccount` (
	`id` INT(16) NOT NULL AUTO_INCREMENT,
	`created` DATETIME NULL DEFAULT current_timestamp(),
	`license` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`name` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`license2` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`fivem` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`steam` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`discord` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`xbl` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`live` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ip` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`current_player` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`lastUpdated` DATETIME NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`permissions` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`tebex` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`history` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`meta` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `permissions` CHECK (json_valid(`permissions`)),
	CONSTRAINT `tebex` CHECK (json_valid(`tebex`)),
	CONSTRAINT `history` CHECK (json_valid(`history`)),
	CONSTRAINT `meta` CHECK (json_valid(`meta`))
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=7
;
-- 
CREATE TABLE `_mkBanList` (
	`id` INT(16) NOT NULL AUTO_INCREMENT,
	`created` DATETIME NULL DEFAULT current_timestamp(),
	`license` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`name` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`license2` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`fivem` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`steam` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`discord` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`xbl` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`live` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ip` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`lastUpdated` DATETIME NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`meta` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `meta` CHECK (json_valid(`meta`))
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
-- 
CREATE TABLE `_mkLog` (
	`id` INT(16) NOT NULL AUTO_INCREMENT,
	`date` DATETIME NULL DEFAULT current_timestamp(),
	`logmsg` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `logmsg` CHECK (json_valid(`logmsg`))
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=598
;