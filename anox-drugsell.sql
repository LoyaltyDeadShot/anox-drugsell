CREATE TABLE IF NOT EXISTS `anox_drugrep` (
  `license` varchar(50) NOT NULL,
  `drug` varchar(50) NOT NULL,
  `rep` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`license`, `drug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;