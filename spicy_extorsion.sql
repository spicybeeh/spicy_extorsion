CREATE TABLE IF NOT EXISTS `spicy_extorsion` (
  `shop_id` varchar(50) NOT NULL,
  `gang_name` varchar(50) DEFAULT NULL,
  `last_payment` timestamp NULL DEFAULT NULL,
  `cooldown` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;