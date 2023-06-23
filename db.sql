-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 23, 2023 at 01:37 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `roobet`
--

-- --------------------------------------------------------

--
-- Table structure for table `bet`
--

CREATE TABLE `bet` (
  `_id` varchar(24) NOT NULL,
  `betAmount` float DEFAULT NULL,
  `balanceType` varchar(20) DEFAULT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `closedOut` tinyint(1) DEFAULT NULL,
  `closeoutComplete` tinyint(1) DEFAULT NULL,
  `paidOut` tinyint(1) DEFAULT NULL,
  `ranHooks` tinyint(1) DEFAULT NULL,
  `attempts` int(11) DEFAULT NULL,
  `betId` varchar(60) DEFAULT NULL,
  `gameName` varchar(50) DEFAULT NULL,
  `gameNameDisplay` varchar(100) DEFAULT NULL,
  `transactionIds` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`transactionIds`)),
  `thirdParty` varchar(30) DEFAULT NULL,
  `category` varchar(30) DEFAULT NULL,
  `gameIdentifier` varchar(50) DEFAULT NULL,
  `payoutValue` float DEFAULT NULL,
  `mult` float DEFAULT NULL,
  `profit` float DEFAULT NULL,
  `gameSessionId` varchar(30) DEFAULT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `won` tinyint(1) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  `closeoutTimestamp` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat`
--

CREATE TABLE `chat` (
  `id` varchar(36) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `message` text DEFAULT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `locale` varchar(5) DEFAULT NULL,
  `userStatus` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `twoFactor` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bet`
--
ALTER TABLE `bet`
  ADD PRIMARY KEY (`_id`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bet`
--
ALTER TABLE `bet`
  ADD CONSTRAINT `bet_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`);

--
-- Constraints for table `chat`
--
ALTER TABLE `chat`
  ADD CONSTRAINT `chat_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
