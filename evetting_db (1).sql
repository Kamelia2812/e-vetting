-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 02, 2026 at 12:05 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `evetting_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `course_id` int(11) NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `course_name` varchar(150) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `lecturer_id` int(11) DEFAULT NULL,
  `vetter_id` int(11) DEFAULT NULL,
  `credit` int(11) DEFAULT NULL,
  `examHour` int(11) DEFAULT NULL,
  `core` varchar(50) DEFAULT NULL,
  `coCategory` varchar(100) DEFAULT NULL,
  `uniOffer` varchar(100) DEFAULT NULL,
  `offerPeriod` varchar(100) DEFAULT NULL,
  `senateRef` varchar(100) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `faculty` varchar(100) DEFAULT 'FSKM'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`course_id`, `course_code`, `course_name`, `created_at`, `lecturer_id`, `vetter_id`, `credit`, `examHour`, `core`, `coCategory`, `uniOffer`, `offerPeriod`, `senateRef`, `department`, `faculty`) VALUES
(1, 'CSE3403', 'SOFTWARE PROJECT MANAGEMENT', '2026-01-21 22:17:11', 3, 2, 3, 2, 'core', 'SOFTWARE', 'Degree', 'session 1 2025/2026', NULL, NULL, 'FSKM'),
(4, 'CSM3313', 'IOT COMPUTING', '2026-01-22 00:48:55', 9, 8, 3, 2, 'core', '', '', 'session 1 2025/2026', '', '', 'FSKM'),
(6, 'CSF3233', 'Cyber Security', '2026-04-07 03:31:36', 5, 6, 3, 2, 'core', '', '', 'session 2 2025/2026', '', '', 'FSKM'),
(8, 'CSA3013', 'Modelling and Simulation', '2026-07-01 18:51:48', 10, 11, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'FSKM');

-- --------------------------------------------------------

--
-- Table structure for table `course_information`
--

CREATE TABLE `course_information` (
  `course_id` int(11) NOT NULL,
  `academic_staff` text DEFAULT NULL,
  `classification` varchar(50) DEFAULT NULL,
  `pre_requisites` text DEFAULT NULL,
  `synopsis` text DEFAULT NULL,
  `teaching_methods` text DEFAULT NULL,
  `assessment_methods` text DEFAULT NULL,
  `transferable_skills` text DEFAULT NULL,
  `special_requirements` text DEFAULT NULL,
  `references_list` text DEFAULT NULL,
  `ca_f2f` decimal(5,2) DEFAULT 0.00,
  `ca_nf2f` decimal(5,2) DEFAULT 0.00,
  `fa_f2f` decimal(5,2) DEFAULT 0.00,
  `fa_nf2f` decimal(5,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `credit_remarks` varchar(255) DEFAULT NULL,
  `year_remarks` varchar(255) DEFAULT NULL,
  `semester_remarks` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_information`
--

INSERT INTO `course_information` (`course_id`, `academic_staff`, `classification`, `pre_requisites`, `synopsis`, `teaching_methods`, `assessment_methods`, `transferable_skills`, `special_requirements`, `references_list`, `ca_f2f`, `ca_nf2f`, `fa_f2f`, `fa_nf2f`, `created_at`, `credit_remarks`, `year_remarks`, `semester_remarks`) VALUES
(4, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, '2026-06-11 03:01:20', NULL, NULL, NULL),
(6, 'Muhammad Syamel', 'Core', '', 'Cybersecurity is the practice of protecting systems, networks, and data from digital attacks while promoting responsible and sustainable use of technology.', NULL, NULL, 'Flexim', 'Computer lab', NULL, 2.00, 0.00, 1.00, 0.00, '2026-04-07 03:45:30', '(2+1)', 'Year 3', 'semester 6');

-- --------------------------------------------------------

--
-- Table structure for table `course_vetters`
--

CREATE TABLE `course_vetters` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `vetter_id` int(11) NOT NULL,
  `is_leader` tinyint(1) NOT NULL DEFAULT 0,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_vetters`
--

INSERT INTO `course_vetters` (`id`, `course_id`, `vetter_id`, `is_leader`, `assigned_at`) VALUES
(4, 4, 8, 0, '2026-06-10 14:25:51'),
(14, 1, 5, 0, '2026-07-01 03:17:30'),
(16, 8, 11, 1, '2026-07-01 20:10:22'),
(17, 8, 2, 0, '2026-07-01 20:10:22'),
(18, 6, 6, 1, '2026-07-01 20:10:44'),
(19, 6, 2, 0, '2026-07-01 20:10:44');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `event_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `event_date` datetime NOT NULL,
  `course_name` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`event_id`, `title`, `event_date`, `course_name`, `created_by`) VALUES
(2, 'Continuous Assessment Due', '2026-07-15 23:59:00', 'BAHASA MANDARIN III', 7),
(3, 'Final Exam Vetting Deadline', '2026-07-20 12:00:00', 'DATA STRUCTURES', 7),
(4, 'JSS Submission Due', '2026-07-25 17:00:00', 'SOFTWARE ENGINEERING', 7),
(5, 'FINAL ASSESSMENT', '2026-07-20 22:00:00', 'Cyber Security', 7),
(6, 'FINAL ASSSESSMENTS', '2026-07-02 22:00:00', 'Cyber Security', 7),
(8, 'FINAL ASSESSMENTS', '2026-07-20 22:00:00', 'Cyber Security', 7);

-- --------------------------------------------------------

--
-- Table structure for table `exam_papers`
--

CREATE TABLE `exam_papers` (
  `paper_id` int(11) NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `course_title` varchar(150) NOT NULL,
  `faculty` varchar(50) NOT NULL DEFAULT 'FSKM',
  `lecturer_id` int(11) NOT NULL,
  `ketua_panel_id` int(11) DEFAULT NULL,
  `ketua_program_id` int(11) DEFAULT NULL,
  `paper_type` varchar(100) NOT NULL DEFAULT 'Final Examination',
  `academic_session` varchar(12) NOT NULL DEFAULT '',
  `semester` tinyint(4) NOT NULL DEFAULT 1,
  `total_questions` int(11) NOT NULL DEFAULT 0,
  `vetted_questions` int(11) NOT NULL DEFAULT 0,
  `status` varchar(30) NOT NULL DEFAULT 'DRAFT',
  `submitted_date` datetime DEFAULT NULL,
  `deadline` varchar(50) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `weightage` decimal(5,2) DEFAULT 0.00,
  `submission_mode` varchar(20) DEFAULT 'Individual',
  `assign_marks` int(11) DEFAULT 100,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `paper_variant` varchar(10) NOT NULL DEFAULT 'MAIN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `exam_papers`
--

INSERT INTO `exam_papers` (`paper_id`, `course_code`, `course_title`, `faculty`, `lecturer_id`, `ketua_panel_id`, `ketua_program_id`, `paper_type`, `academic_session`, `semester`, `total_questions`, `vetted_questions`, `status`, `submitted_date`, `deadline`, `remarks`, `instructions`, `weightage`, `submission_mode`, `assign_marks`, `created_at`, `updated_at`, `paper_variant`) VALUES
(1, 'CSM3313', 'IOT COMPUTING', 'FSKM', 9, NULL, NULL, 'Final Exam', '2024/2025', 2, 7, 0, 'APPROVED', '2026-06-11 10:36:06', '2026-06-30', '', NULL, 0.00, 'Individual', 100, '2026-06-01 23:14:44', '2026-06-11 10:36:58', 'MAIN'),
(2, 'CSM3313', 'IOT COMPUTING', 'FSKM', 9, NULL, NULL, 'Final Exam', '2024/2025', 2, 7, 0, 'APPROVED', '2026-06-09 12:12:16', '2026-03-26', '', NULL, 0.00, 'Individual', 100, '2026-06-09 11:45:11', '2026-06-11 08:47:32', 'MAIN'),
(4, 'CSF3233', 'Cyber Security', 'FSKM', 5, NULL, NULL, 'Final Examination', '2024/2025', 2, 5, 0, 'UNDER_REVIEW', '2026-06-16 09:11:30', NULL, NULL, 'Answer ALL questions in Section A (Objective) and THREE (3) questions from Section B. Time allowed: 2 hours.', 0.00, 'Individual', 100, '2026-06-16 09:11:30', '2026-06-16 10:00:00', 'MAIN'),
(5, 'CSF3233', 'Cyber Security', 'FSKM', 5, NULL, NULL, 'Mid-Semester Examination', '2024/2025', 1, 5, 0, 'NEEDS_IMPROVEMENT', '2026-06-16 13:05:42', NULL, NULL, 'Answer ALL questions. Section A: Multiple Choice (20 marks). Section B: Short Answer (30 marks). Time allowed: 1 hour 30 minutes.', 0.00, 'Individual', 50, '2026-06-16 13:05:42', '2026-06-16 13:46:17', 'MAIN'),
(6, 'CSF3233', 'Cyber Security', 'FSKM', 5, NULL, NULL, 'Final Examination', '2023/2024', 2, 5, 0, 'FINALIZED', '2024-03-10 09:00:00', NULL, NULL, 'Answer ALL questions in Section A (Objective) and THREE (3) questions from Section B. Time allowed: 2 hours.', 0.00, 'Individual', 100, '2026-06-16 13:43:32', '2026-06-16 13:43:32', 'MAIN'),
(7, 'CSE3403', 'SOFTWARE PROJECT MANAGEMENT', 'FSKM', 3, NULL, NULL, 'Individual Assignment', '2026/2027', 1, 0, 0, 'SUBMITTED', NULL, '2026-08-01', NULL, 'Please complete the project proposal document.', 20.00, 'Individual', 100, '2026-07-01 11:17:30', '2026-07-01 11:17:30', 'MAIN'),
(8, 'CSF3233', 'Cyber Security', 'FSKM', 5, NULL, NULL, 'Individual Assignment', '2026/2027', 1, 0, 0, 'SUBMITTED', '2026-06-11 11:45:29', '2026-08-01', NULL, 'You are required to perform a comprehensive vulnerability assessment on a simulated corporate network environment. Your report should include an executive summary, methodology (using tools like Nmap, Wireshark, or Nessus), detailed findings with CVSS scores, and actionable mitigation recommendations. The final report must be submitted in PDF format.', 30.00, 'Individual', 100, '2026-07-01 11:20:45', '2026-07-01 15:16:15', 'MAIN'),
(9, 'CSF3233', 'Cyber Security', 'FSKM', 5, NULL, NULL, 'Lab Report', '2025/2026', 2, 0, 0, 'DRAFT', NULL, '2026-06-18', NULL, '<h1>Group Project: Cybersecurity</h1>\r\n<p><strong>Project Theme:</strong> Use of NotebookLM to Support Cybersecurity Group Project Research and Development</p>\r\n<p><strong>Submission Mode:</strong> Compressed Files (.zip) Submission to epembelajaran</p>\r\n\r\n<h2>1. Introduction</h2>\r\n<p>This group project requires students to use NotebookLM as a structured academic support tool throughout the development of a cybersecurity-focused group project. The purpose of this task is to help students organize project references, synthesize information from multiple sources, identify important cybersecurity issues, and prepare supporting materials for discussion and presentation.</p>\r\n\r\n<h2>2. Objectives</h2>\r\n<ol>\r\n  <li>Organize and manage cybersecurity-related references systematically;</li>\r\n  <li>Use NotebookLM to summarize, compare, and synthesize information from selected cybersecurity sources;</li>\r\n  <li>Generate useful supporting materials for cybersecurity project development and presentation;</li>\r\n  <li>Critically reflect on the benefits and limitations of AI-assisted academic tools in cybersecurity learning; and</li>\r\n  <li>Demonstrate responsible and ethical use of AI in academic work.</li>\r\n</ol>\r\n\r\n<h2>3. Group Requirement</h2>\r\n<ul>\r\n  <li>This assignment must be completed in groups.</li>\r\n  <li>Each group may consist of a maximum of <strong>3 members</strong> only.</li>\r\n  <li>Each group is required to create one shared NotebookLM notebook specifically for the assigned cybersecurity project topic.</li>\r\n  <li>All group members are expected to contribute to the notebook development, use, review, and validation process.</li>\r\n</ul>\r\n\r\n<h2>4. Task Requirements</h2>\r\n<ul>\r\n  <li><strong>Create a Group Notebook:</strong> Name it clearly according to the group number and project title (e.g. Group 2 - Ransomware Defensive Strategies).</li>\r\n  <li><strong>Upload Relevant Sources:</strong> Upload 5 to 8 quality sources (journal articles, conference papers, etc.).</li>\r\n  <li><strong>Generate Supporting Artifacts:</strong> Produce at least two meaningful NotebookLM-generated artifacts (summary notes, mind map, FAQ, etc.).</li>\r\n</ul>\r\n\r\n<h2>5. Deliverables</h2>\r\n<ul>\r\n  <li><strong>Final Report (PDF):</strong> 8 to 10 pages only.</li>\r\n  <li><strong>Source List:</strong> A document listing all uploaded sources.</li>\r\n  <li><strong>Evidence of Use:</strong> Screenshots of prompts and responses.</li>\r\n  <li><strong>Artifacts:</strong> At least two NotebookLM artifacts.</li>\r\n  <li><strong>Group Reflection:</strong> Approx. 500 words on NotebookLM use.</li>\r\n  <li><strong>Manual Verification Section:</strong> Explain what was verified manually (max 1 page).</li>\r\n</ul>', 20.00, 'Group', 100, '2026-07-02 02:51:48', '2026-07-02 03:47:03', 'MAIN'),
(10, 'CSA3013', 'Modelling and Simulation', 'FSKM', 10, NULL, NULL, 'Lab Report', '2024/2025', 1, 0, 0, 'DRAFT', NULL, '2025-06-15', NULL, '<h1>Group Project Report Structure: Modelling and Simulation</h1>\r\n\r\n<h2>1. Cover Page (1 Page)</h2>\r\n<ul>\r\n  <li>UMT Logo</li>\r\n  <li>Leader Name</li>\r\n  <li>Members Names</li>\r\n  <li>Matric Numbers</li>\r\n  <li>Subject Name and Code</li>\r\n  <li>Programme</li>\r\n</ul>\r\n\r\n<h2>2. Introduction (at least 1 Page)</h2>\r\n<ul>\r\n  <li><strong>Project Overview:</strong> Briefly introduce the simulation project, explaining its purpose and what it aims to achieve.</li>\r\n  <li><strong>Objective:</strong> Clearly state the objectives of the simulation project. What is the project trying to solve, analyze, or simulate?</li>\r\n  <li><strong>Importance:</strong> Explain the significance of the simulation in the context of the subject or industry.</li>\r\n</ul>\r\n\r\n<h2>3. Simulation Analysis & Issues (at least 8 Pages)</h2>\r\n<ul>\r\n  <li><strong>Content:</strong> Provide a detailed analysis of the simulation, including any issues or challenges encountered.</li>\r\n  <li><strong>Solutions/Answers:</strong> For each issue or challenge, offer solutions or answers with clear explanations.</li>\r\n  <li><strong>Supporting Evidence:</strong> Screenshots of the simulation results or any issues faced should be included to support your analysis and solutions. Note: Ensure that your screenshots are clear and relevant to the issues you are discussing.</li>\r\n</ul>\r\n\r\n<h2>4. Summary (1 Page)</h2>\r\n<ul>\r\n  <li>Provide a concise summary of your findings and analysis from the previous section.</li>\r\n  <li>Highlight the most important insights gained from the simulation analysis, as well as any conclusions or recommendations.</li>\r\n</ul>\r\n\r\n<h2>Additional Guidelines:</h2>\r\n<ol>\r\n  <li><strong>Formatting:</strong> Use Times New Roman, Size 12, 1.5 line spacing, 1 inch margins.</li>\r\n  <li><strong>Page Numbering:</strong> Start page numbering from the second page.</li>\r\n  <li><strong>Clarity:</strong> Ensure your explanations are clear and easy to follow.</li>\r\n</ol>', 30.00, 'Group', 100, '2026-07-02 02:51:48', '2026-07-02 04:24:40', 'MAIN');

-- --------------------------------------------------------

--
-- Table structure for table `jss`
--

CREATE TABLE `jss` (
  `jss_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `course_id` int(11) DEFAULT NULL,
  `lecturer_id` int(11) NOT NULL,
  `faculty` varchar(100) DEFAULT 'FSKM',
  `programme` varchar(150) DEFAULT NULL,
  `academic_session` varchar(20) DEFAULT NULL,
  `semester` int(11) DEFAULT 1,
  `assessment_type` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jss`
--

INSERT INTO `jss` (`jss_id`, `paper_id`, `course_id`, `lecturer_id`, `faculty`, `programme`, `academic_session`, `semester`, `assessment_type`, `created_at`, `updated_at`) VALUES
(1, 1, 4, 9, 'FSKM', 'Bachelor of Science Computer with Informatic Maritme', NULL, 1, 'Final Exam', '2026-06-09 03:51:25', '2026-06-09 03:51:25'),
(2, 2, 4, 9, 'FSKM', '', NULL, 1, 'Final Exam', '2026-06-09 04:11:50', '2026-06-09 04:11:50'),
(4, 4, 6, 5, 'FSKM', NULL, '2024/2025', 2, 'Final Examination', '2026-06-16 01:11:30', '2026-06-16 02:00:00'),
(5, 5, 6, 5, 'FSKM', NULL, '2024/2025', 1, 'Mid-Semester Examination', '2026-06-16 05:05:42', '2026-06-16 05:05:42'),
(6, 6, 6, 5, 'FSKM', NULL, '2023/2024', 2, 'Final Examination', '2024-03-10 01:00:00', '2026-06-16 05:43:32');

-- --------------------------------------------------------

--
-- Table structure for table `jss_rows`
--

CREATE TABLE `jss_rows` (
  `row_id` int(11) NOT NULL,
  `jss_id` int(11) NOT NULL,
  `row_order` int(11) NOT NULL DEFAULT 1,
  `topic_name` varchar(200) DEFAULT NULL,
  `lecture_hours` decimal(4,1) DEFAULT 0.0,
  `question_no` varchar(20) DEFAULT NULL,
  `plo` varchar(20) DEFAULT NULL,
  `clo` varchar(20) DEFAULT NULL,
  `question_type` varchar(5) DEFAULT NULL,
  `marks` int(11) DEFAULT 0,
  `taxonomy_level` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jss_rows`
--

INSERT INTO `jss_rows` (`row_id`, `jss_id`, `row_order`, `topic_name`, `lecture_hours`, `question_no`, `plo`, `clo`, `question_type`, `marks`, `taxonomy_level`) VALUES
(8, 1, 0, 'Chapter 1', 1.5, '1', '', 'CLO1', 'O', 10, 'C1'),
(9, 1, 1, 'Chapter 1', 2.0, '2', '', 'CLO2', 'O', 10, 'C1'),
(10, 1, 2, 'Chapter 3', 3.0, '3', '', 'CLO1', 'O', 10, 'C1'),
(11, 1, 3, 'Chapter 4', 0.0, '4', '', 'CLO1', 'O', 10, 'C1'),
(12, 1, 4, 'Chapter 2', 1.5, '5', '', 'CLO1', 'S', 20, 'C2'),
(13, 1, 5, 'Chapter 1', 1.5, '6', '', 'CLO1', 'S', 20, 'C2'),
(14, 1, 6, 'Chapter 5', 2.0, '7', '', 'CLO1', 'E', 20, 'C3'),
(15, 2, 0, 'Chapter 1', 1.0, '1', '', 'CLO1', 'O', 11, 'C1'),
(16, 2, 1, 'Chapter 3', 2.0, '2', '', 'CLO1', 'O', 10, 'C2'),
(17, 2, 2, 'Chapter 3', 0.0, '3', '', 'CLO1', 'O', 10, 'C1'),
(18, 2, 3, 'Chapter 2', 2.0, '4', '', 'CLO1', 'O', 10, 'C1'),
(19, 2, 4, 'Chapter 4', 1.5, '5', '', 'CLO3', 'S', 20, 'C3'),
(20, 2, 5, 'Chapter 5', 1.0, '6', '', 'CLO3', 'S', 19, 'C4'),
(21, 2, 6, 'Chapter 5', 0.5, '7', '', 'CLO3', 'E', 20, 'C3'),
(22, 4, 1, 'Intro to Cyber Security', 0.0, '1', 'PLO1', 'CLO1', 'Objec', 4, 'C2'),
(23, 4, 2, 'Security Principles (CIA)', 0.0, '2', 'PLO1', 'CLO1', 'Objec', 4, 'C1'),
(24, 4, 3, 'Cryptography', 0.0, '3', 'PLO2', 'CLO2', 'Objec', 4, 'C1'),
(25, 4, 4, 'Threat Actors and Attack Lifecycle', 0.0, '4', 'PLO2', 'CLO2', 'Struc', 18, 'C3'),
(26, 4, 5, 'Incident Response and Digital Forensics', 0.0, '5', 'PLO3', 'CLO3', 'Essay', 70, 'C5'),
(27, 5, 1, 'Introduction to Cyber Security', 0.0, '1', 'PLO1', 'CLO1', 'Objec', 4, 'C1'),
(28, 5, 2, 'Security Principles', 0.0, '2', 'PLO1', 'CLO1', 'Objec', 4, 'C2'),
(29, 5, 3, 'Cryptography', 0.0, '3', 'PLO2', 'CLO2', 'Objec', 4, 'C2'),
(30, 5, 4, 'Network Security', 0.0, '4', 'PLO2', 'CLO2', 'Objec', 4, 'C1'),
(31, 5, 5, 'Application Security', 0.0, '5', 'PLO2', 'CLO2', 'Struc', 34, 'C4'),
(32, 6, 1, 'Introduction to Cyber Security', 0.0, '1', 'PLO1', 'CLO1', 'Objec', 4, 'C1'),
(33, 6, 2, 'Network Security', 0.0, '2', 'PLO2', 'CLO2', 'Objec', 4, 'C1'),
(34, 6, 3, 'Cryptography', 0.0, '3', 'PLO2', 'CLO2', 'Objec', 4, 'C1'),
(35, 6, 4, 'Cryptography', 0.0, '4', 'PLO2', 'CLO2', 'Struc', 18, 'C4'),
(36, 6, 5, 'Security Principles (DiD)', 0.0, '5', 'PLO3', 'CLO3', 'Essay', 70, 'C5');

-- --------------------------------------------------------

--
-- Table structure for table `lecturer_courses`
--

CREATE TABLE `lecturer_courses` (
  `lecturer_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lecturer_courses`
--

INSERT INTO `lecturer_courses` (`lecturer_id`, `course_id`, `assigned_at`) VALUES
(3, 6, '2026-06-16 01:11:30'),
(5, 6, '2026-06-16 02:00:14'),
(6, 6, '2026-04-07 04:00:53'),
(9, 4, '2026-06-01 14:40:21'),
(10, 8, '2026-07-01 20:10:22');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_name` varchar(200) NOT NULL,
  `sender_role` varchar(50) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message_reads`
--

CREATE TABLE `message_reads` (
  `user_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `last_read_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `message_reads`
--

INSERT INTO `message_reads` (`user_id`, `paper_id`, `last_read_at`) VALUES
(5, 4, '2026-06-23 04:44:35'),
(5, 5, '2026-06-24 20:06:49'),
(5, 8, '2026-07-01 19:46:30'),
(5, 9, '2026-07-01 20:23:51'),
(6, 4, '2026-07-01 03:19:11'),
(6, 5, '2026-07-01 07:14:56'),
(6, 8, '2026-07-01 19:49:09'),
(10, 10, '2026-07-01 20:24:20');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assessment_id` int(11) DEFAULT NULL,
  `summary` varchar(255) NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `assessment_id`, `summary`, `is_read`, `created_at`) VALUES
(1, 8, 2, 'aisyah submitted CSM3313 (IOT COMPUTING) for 2024/2025 Sem 2 — ready for vetting.', 0, '2026-06-09 04:12:16'),
(2, 7, 2, 'aisyah submitted CSM3313 (IOT COMPUTING) for 2024/2025 Sem 2 — ready for vetting.', 0, '2026-06-09 04:12:16'),
(3, 8, 1, 'aisyah submitted CSM3313 (IOT COMPUTING) for 2024/2025 Sem 2 — ready for vetting.', 0, '2026-06-09 04:12:30'),
(4, 7, 1, 'aisyah submitted CSM3313 (IOT COMPUTING) for 2024/2025 Sem 2 — ready for vetting.', 1, '2026-06-09 04:12:30'),
(5, 9, 2, 'CSM3313 (IOT COMPUTING) — 2024/2025 Sem 2 : Vetting verdict: Approved', 0, '2026-06-11 00:47:32'),
(6, 9, 1, 'CSM3313 (IOT COMPUTING) — 2024/2025 Sem 2 : Vetting verdict: Needs Improvement — sent back for revision', 0, '2026-06-11 02:14:59'),
(7, 9, 1, 'CSM3313 (IOT COMPUTING) — 2024/2025 Sem 2 : Vetting verdict: Approved', 0, '2026-06-11 02:36:58'),
(10, 6, 4, 'CSF3233 (Cyber Security) 2024/2025 Sem 2 ù Final Examination submitted by Amelia for vetting review.', 1, '2026-06-16 02:00:14'),
(11, 2, 4, 'CSF3233 (Cyber Security) 2024/2025 Sem 2 ù Final Examination submitted by Amelia for vetting review.', 0, '2026-06-16 02:00:14'),
(12, 6, 5, 'CSF3233 (Cyber Security) 2024/2025 Sem 1 - Mid-Semester Examination submitted by Amelia for vetting review.', 1, '2026-06-16 05:05:42'),
(13, 2, 5, 'CSF3233 (Cyber Security) 2024/2025 Sem 1 - Mid-Semester Examination submitted by Amelia for vetting review.', 0, '2026-06-16 05:05:42'),
(14, 5, 6, 'CSF3233 (Cyber Security) 2023/2024 Sem 2 - Final Examination has been FINALIZED and sent to Fakulti.', 1, '2024-04-01 02:00:00'),
(15, 6, 6, 'CSF3233 (Cyber Security) 2023/2024 Sem 2 - Final Examination has been FINALIZED.', 1, '2024-04-01 02:00:00'),
(16, 5, 5, 'CSF3233 (Cyber Security) 2024/2025 Sem 1 - Mid-Semester Examination requires improvement. Please review the vetter checklist feedback and resubmit.', 1, '2026-06-16 05:46:17');

-- --------------------------------------------------------

--
-- Table structure for table `paper_section_comments`
--

CREATE TABLE `paper_section_comments` (
  `id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `section` enum('JSS','SCHEME') NOT NULL DEFAULT 'JSS',
  `vetter_id` int(11) NOT NULL,
  `vetter_name` varchar(200) DEFAULT NULL,
  `comment_text` text NOT NULL,
  `verdict` enum('APPROVED','NEEDS_REVISION','REJECTED') DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `paper_section_comments`
--

INSERT INTO `paper_section_comments` (`id`, `paper_id`, `section`, `vetter_id`, `vetter_name`, `comment_text`, `verdict`, `created_at`, `updated_at`) VALUES
(1, 1, 'JSS', 2, 'Ali', 'The overall distribution of questions across chapters aligns well with the syllabus. However, Chapter 4 seems slightly underrepresented.', '', '2026-07-01 22:44:26', '2026-07-01 22:44:26'),
(2, 1, 'SCHEME', 6, 'Muhammad Syamel', 'The marking scheme is very clear and provides excellent guidance for part-time graders. Well done.', '', '2026-07-01 22:44:26', '2026-07-01 22:44:26'),
(3, 8, 'JSS', 2, 'Ali', 'The matrix nicely covers CLO1-3 and clearly outlines the vulnerability assessment requirements. It looks good.', '', '2026-07-01 22:44:46', '2026-07-01 22:44:46'),
(4, 8, 'SCHEME', 6, 'Muhammad Syamel', 'The 4-part marking schema matrix is robust. The only thing I would add is a penalty clause for late submissions.', '', '2026-07-01 22:44:46', '2026-07-01 22:44:46');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `question_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `question_no` varchar(10) NOT NULL,
  `question_type` enum('OBJECTIVE','STRUCTURE','ESSAY') NOT NULL DEFAULT 'OBJECTIVE',
  `question_format` enum('SIMPLE','COMPLEX') NOT NULL DEFAULT 'SIMPLE',
  `question_text` text NOT NULL,
  `statement_1` varchar(500) DEFAULT NULL,
  `statement_2` varchar(500) DEFAULT NULL,
  `statement_3` varchar(500) DEFAULT NULL,
  `statement_4` varchar(500) DEFAULT NULL,
  `question_text_ms` text DEFAULT NULL,
  `marks` int(11) NOT NULL DEFAULT 0,
  `chapter` varchar(100) DEFAULT NULL,
  `taxonomy_level` varchar(10) NOT NULL DEFAULT 'C1',
  `clo_mapping` varchar(20) DEFAULT 'CLO1',
  `status` enum('DRAFT','APPROVED','NEEDS_REVISION','REJECTED') NOT NULL DEFAULT 'DRAFT',
  `choice_a` text DEFAULT NULL,
  `choice_b` text DEFAULT NULL,
  `choice_c` text DEFAULT NULL,
  `choice_d` text DEFAULT NULL,
  `correct_answer` varchar(1) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `table_data` text DEFAULT NULL,
  `model_answer` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`question_id`, `paper_id`, `question_no`, `question_type`, `question_format`, `question_text`, `statement_1`, `statement_2`, `statement_3`, `statement_4`, `question_text_ms`, `marks`, `chapter`, `taxonomy_level`, `clo_mapping`, `status`, `choice_a`, `choice_b`, `choice_c`, `choice_d`, `correct_answer`, `image_url`, `table_data`, `model_answer`, `created_at`) VALUES
(1, 1, '1', 'OBJECTIVE', 'SIMPLE', 'what is iot?', '', '', '', '', '', 10, 'Chapter 1', 'C1', 'CLO1', 'DRAFT', 'internet of things', 'internet of technology', 'internal of technology', 'interconnection of technology', 'A', '', '', NULL, '2026-06-01 23:14:44'),
(2, 1, '2', 'OBJECTIVE', 'SIMPLE', 'How many layers are there in standard IoT architecture?', '', '', '', '', '', 10, 'Chapter 1', 'C1', 'CLO2', 'DRAFT', '5', '6', '7', '8', 'A', '', '', NULL, '2026-06-01 23:14:44'),
(3, 1, '3', 'OBJECTIVE', 'SIMPLE', 'Once the data sensing is done, ____ are required to facilitate the data transfer.', '', '', '', '', '', 10, 'Chapter 3', 'C1', 'CLO1', 'DRAFT', 'sensor', 'gps', 'cloud device', 'gateways', 'D', '', '', NULL, '2026-06-01 23:14:44'),
(4, 1, '4', 'OBJECTIVE', 'SIMPLE', ' Which of the following is an advantage of the Internet of Things (IoT)?', '', '', '', '', '', 10, 'Chapter 4', 'C2', 'CLO1', 'DRAFT', 'Increased human effort', ' Reduced resource utilisation ', 'Enhanced data collection', ' Decreased security', 'C', '', '', NULL, '2026-06-01 23:14:44'),
(5, 1, '5', 'STRUCTURE', 'SIMPLE', 'what is the topmost layer of the IoT architecture? explain. ', NULL, NULL, NULL, NULL, '', 20, 'Chapter 2', 'C2', 'CLO1', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-01 23:14:44'),
(6, 1, '6', 'STRUCTURE', 'SIMPLE', 'What is a significant disadvantages of IoT? and why?', NULL, NULL, NULL, NULL, '', 20, 'Chapter 1', 'C3', 'CLO1', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-01 23:14:44'),
(7, 1, '7', 'ESSAY', 'SIMPLE', 'What is the challenge of IoT implementation in smart cities? explain it with examples.', NULL, NULL, NULL, NULL, '', 20, 'Chapter 5', 'C3', 'CLO1', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-01 23:14:44'),
(8, 2, '1', 'OBJECTIVE', 'SIMPLE', ' When was the term IoT first coined?', '', '', '', '', '', 11, 'Chapter 1', 'C1', 'CLO1', 'DRAFT', '1994', '1995', '1998', '1999', 'D', '', '', NULL, '2026-06-09 11:45:11'),
(9, 2, '2', 'OBJECTIVE', 'SIMPLE', 'In IoT architecture, which layer/layers use networking technologies like 3G, 4G, UTMS, etc. to transfer data?', '', '', '', '', '', 10, 'Chapter 3', 'C2', 'CLO1', 'DRAFT', 'Application Layer', ' Perception Layer', ' Network Layer', ' All of the above', 'C', '', '', NULL, '2026-06-09 11:45:11'),
(10, 2, '3', 'OBJECTIVE', 'SIMPLE', 'Which components are typically involved in the data transfer process within the IoT ecosystem?', '', '', '', '', '', 10, 'Chapter 3', 'C1', 'CLO1', 'DRAFT', 'Desktop computers and printers', ' Cloud Computing and Big Data ', 'Paper documents and physical files ', 'Mechanical switches and knobs', 'B', '', '', NULL, '2026-06-09 11:45:11'),
(11, 2, '4', 'OBJECTIVE', 'SIMPLE', 'What is the challenge of IoT implementation in smart cities?', '', '', '', '', '', 10, 'Chapter 2', 'C1', 'CLO1', 'DRAFT', 'Lack of urban space', ' Security and data privacy issues', ' Too many trees ', 'High literacy rates', 'B', '', '', NULL, '2026-06-09 11:45:11'),
(12, 2, '5', 'STRUCTURE', 'SIMPLE', 'hich database is commonly used for IoT applications that require real-time data analysis? explain', NULL, NULL, NULL, NULL, '', 20, 'Chapter 4', 'C3', 'CLO3', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rjrisgrpjspi', '2026-06-09 11:45:11'),
(13, 2, '6', 'STRUCTURE', 'SIMPLE', 'Which feature is a significant advantage of IPv6 over IPv4 in IoT communication? explain why?', NULL, NULL, NULL, NULL, '', 19, 'Chapter 5', 'C4', 'CLO3', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'more space', '2026-06-09 11:45:11'),
(14, 2, '7', 'ESSAY', 'SIMPLE', 'Which IEEE standard is specifically designed for short-range communication within 10 meters in IoT applications?Explain why?', NULL, NULL, NULL, NULL, '', 20, 'Chapter 5', 'C3', 'CLO3', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'prnprnbrpsinb', '2026-06-09 11:45:11'),
(20, 4, '1', 'OBJECTIVE', 'SIMPLE', 'Which of the following BEST describes a Man-in-the-Middle (MitM) attack?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 1: Introduction to Cyber Security', 'C2', 'CLO1', 'DRAFT', 'An attacker intercepts communication between two parties without their knowledge.', 'An attacker floods a server with traffic to make it unavailable.', 'An attacker tricks a user into revealing credentials via a fake website.', 'An attacker installs malicious software on a victim machine remotely.', 'A', NULL, NULL, 'A - The attacker positions between two parties, reading or altering data in transit.', '2026-06-16 09:11:30'),
(21, 4, '2', 'OBJECTIVE', 'SIMPLE', 'In the CIA Triad, which principle ensures that information is accessible only to authorised parties?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 2: Security Principles', 'C1', 'CLO1', 'DRAFT', 'Availability', 'Integrity', 'Confidentiality', 'Authentication', 'C', NULL, NULL, 'C - Confidentiality restricts access to authorised entities only.', '2026-06-16 09:11:30'),
(22, 4, '3', 'OBJECTIVE', 'SIMPLE', 'Which cryptographic algorithm is classified as an asymmetric key algorithm?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 3: Cryptography', 'C1', 'CLO2', 'DRAFT', 'AES (Advanced Encryption Standard)', 'DES (Data Encryption Standard)', 'RSA (Rivest-Shamir-Adleman)', '3DES (Triple DES)', 'C', NULL, NULL, 'C - RSA uses a public/private key pair. AES, DES, and 3DES are symmetric algorithms.', '2026-06-16 09:11:30'),
(23, 4, '4', 'STRUCTURE', 'COMPLEX', 'Explain the THREE (3) phases of a typical cyber attack lifecycle (Reconnaissance, Exploitation, Post-Exploitation). For each phase, provide ONE (1) real-world technique or tool used by attackers.', NULL, NULL, NULL, NULL, NULL, 18, 'Chapter 4: Threat Actors and Attack Lifecycle', 'C3', 'CLO2', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Reconnaissance (6m): Gathering target information - OSINT tools (Maltego, Shodan), port scanning (Nmap). Exploitation (6m): Using vulnerabilities to gain access - SQL injection via sqlmap, exploiting CVEs with Metasploit. Post-Exploitation (6m): Maintaining access - privilege escalation, lateral movement, data exfiltration using Mimikatz.', '2026-06-16 09:11:30'),
(24, 4, '5', 'ESSAY', 'COMPLEX', 'An organisation suffered a ransomware attack encrypting all critical data. As a cyber security consultant, propose a comprehensive Incident Response (IR) plan addressing: (a) Initial containment steps after detection. (b) Evidence preservation and forensic analysis. (c) Recovery strategy including backup validation. (d) Post-incident review and preventive measures.', NULL, NULL, NULL, NULL, NULL, 70, 'Chapter 6: Incident Response and Digital Forensics', 'C5', 'CLO3', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '(a) Containment (15m): Isolate affected systems, disable remote access, notify IR team. (b) Forensics (15m): Preserve disk images, collect memory dumps, analyse event logs, maintain chain of custody. (c) Recovery (20m): Restore from clean backup, validate via hash, patch vulnerability, phased restoration with monitoring. (d) Post-incident (20m): Root cause analysis, update IR plan, implement MFA, conduct staff awareness training.', '2026-06-16 09:11:30'),
(25, 5, '1', 'OBJECTIVE', 'SIMPLE', 'Which of the following is an example of a social engineering attack?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 1: Introduction to Cyber Security', 'C1', 'CLO1', 'DRAFT', 'SQL Injection', 'Phishing email impersonating a bank', 'Buffer overflow exploit', 'ARP spoofing', 'B', NULL, NULL, 'B - Phishing is a social engineering technique that manipulates users into revealing sensitive information by impersonating a trusted entity.', '2026-06-16 13:05:42'),
(26, 5, '2', 'OBJECTIVE', 'SIMPLE', 'What does the principle of LEAST PRIVILEGE state?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 2: Security Principles', 'C2', 'CLO1', 'DRAFT', 'Users should have the maximum access needed to perform any possible task.', 'All users must share a single administrator account.', 'Users and systems should be granted only the minimum access required to perform their duties.', 'Privileged accounts should never require a password.', 'C', NULL, NULL, 'C - Least privilege limits access rights to only what is strictly needed, reducing the attack surface and limiting damage from compromised accounts.', '2026-06-16 13:05:42'),
(27, 5, '3', 'OBJECTIVE', 'SIMPLE', 'Which hashing algorithm is currently considered MOST secure for password storage?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 3: Cryptography', 'C2', 'CLO2', 'DRAFT', 'MD5', 'SHA-1', 'bcrypt', 'CRC32', 'C', NULL, NULL, 'C - bcrypt is a password hashing function designed to be computationally expensive and includes a salt, making it resistant to brute-force and rainbow table attacks. MD5 and SHA-1 are cryptographically broken.', '2026-06-16 13:05:42'),
(28, 5, '4', 'OBJECTIVE', 'SIMPLE', 'A firewall that inspects the state of active connections and makes decisions based on context is called a:', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 5: Network Security', 'C1', 'CLO2', 'DRAFT', 'Packet filtering firewall', 'Stateful inspection firewall', 'Application layer gateway', 'Proxy firewall', 'B', NULL, NULL, 'B - A stateful inspection firewall tracks the state of network connections (SYN, SYN-ACK, ACK) and allows or denies packets based on the connection state and context.', '2026-06-16 13:05:42'),
(29, 5, '5', 'STRUCTURE', 'COMPLEX', 'A university database storing student records was found to be vulnerable to SQL injection. (a) Explain how an attacker could exploit this vulnerability to extract all student records. (b) Describe TWO (2) preventive measures the university should implement to mitigate SQL injection attacks.', NULL, NULL, NULL, NULL, NULL, 34, 'Chapter 4: Application Security', 'C4', 'CLO2', 'DRAFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '(a) Exploitation (14m): Attacker identifies an input field that passes data directly to a SQL query (e.g., login form). Injects malicious SQL such as \' OR \'1\'=\'1 to bypass authentication, or uses UNION SELECT to extract data from other tables. Example: entering admin\'-- as username comments out the password check, granting unauthorized access. With UNION attacks, attacker enumerates table names via information_schema and retrieves all records. (b) Prevention (10m each, 20m total): (1) Parameterised queries/prepared statements: separate SQL code from user input so injected text is treated as data, not executable code. (2) Input validation and sanitisation: whitelist acceptable input formats, escape special characters, reject unexpected input patterns. Additional: least privilege on DB accounts, WAF deployment, stored procedures.', '2026-06-16 13:05:42'),
(30, 6, '1', 'OBJECTIVE', 'SIMPLE', 'Which of the following BEST defines the term \"vulnerability\" in the context of information security?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 1: Introduction to Cyber Security', 'C1', 'CLO1', 'APPROVED', 'A threat actor targeting a specific organisation.', 'A weakness in a system that can be exploited by a threat.', 'A deliberate action taken to compromise a system.', 'The probability of a security incident occurring.', 'B', NULL, NULL, 'B - A vulnerability is a flaw or weakness in a system that can be exploited by a threat actor to gain unauthorised access or cause harm.', '2026-06-16 13:43:32'),
(31, 6, '2', 'OBJECTIVE', 'SIMPLE', 'Which of the following protocols provides SECURE remote login over an encrypted channel?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 5: Network Security', 'C1', 'CLO2', 'APPROVED', 'Telnet', 'FTP', 'SSH', 'HTTP', 'C', NULL, NULL, 'C - SSH (Secure Shell) encrypts all data including authentication credentials. Telnet, FTP, and HTTP transmit data in plaintext.', '2026-06-16 13:43:32'),
(32, 6, '3', 'OBJECTIVE', 'SIMPLE', 'A digital certificate is used to verify the identity of entities in a network. Which authority issues digital certificates?', NULL, NULL, NULL, NULL, NULL, 4, 'Chapter 3: Cryptography', 'C1', 'CLO2', 'APPROVED', 'Domain Name System (DNS)', 'Internet Service Provider (ISP)', 'Certificate Authority (CA)', 'Firewall Administrator', 'C', NULL, NULL, 'C - A Certificate Authority (CA) is a trusted entity that issues digital certificates, verifying the identity of certificate holders.', '2026-06-16 13:43:32'),
(33, 6, '4', 'STRUCTURE', 'COMPLEX', 'Describe the differences between symmetric and asymmetric encryption. Include ONE (1) example algorithm for each type and explain a scenario where each would be preferred.', NULL, NULL, NULL, NULL, NULL, 18, 'Chapter 3: Cryptography', 'C4', 'CLO2', 'APPROVED', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Symmetric (6m): Uses single shared key for both encryption and decryption. Fast, efficient for large data. Example: AES. Preferred for encrypting bulk data (e.g., file encryption, disk encryption). Asymmetric (6m): Uses key pair - public key (encrypt) and private key (decrypt). Slower but eliminates key distribution problem. Example: RSA. Preferred for secure key exchange, digital signatures, and authentication. Scenario comparison (6m): Symmetric preferred in VPN tunnel encryption after key exchange; asymmetric preferred in initial TLS handshake to securely exchange the symmetric session key.', '2026-06-16 13:43:32'),
(34, 6, '5', 'ESSAY', 'COMPLEX', 'Evaluate the effectiveness of a Defence-in-Depth (DiD) strategy in protecting an organisation\'s information assets. Your answer should cover: (a) The concept and layers of DiD. (b) TWO (2) specific controls at different layers with justification. (c) Limitations of DiD and how organisations can address them.', NULL, NULL, NULL, NULL, NULL, 70, 'Chapter 2: Security Principles', 'C5', 'CLO3', 'APPROVED', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '(a) DiD Concept (20m): Multiple overlapping layers of security controls so that if one layer fails, others still provide protection. Layers include: physical, network, host, application, data, and user. Borrowed from military strategy. (b) Specific controls (25m each = 25m): Network layer - firewall with IDS/IPS to filter and monitor traffic, justification: prevents perimeter breaches and detects anomalies. Application layer - input validation and WAF, justification: prevents injection attacks and cross-site scripting at application level. (c) Limitations (25m): Complexity increases management overhead; layers may create false sense of security; insider threats bypass most layers; high cost. Addressed by: regular security audits, zero-trust model adoption, privileged access management, and continuous monitoring with SIEM.', '2026-06-16 13:43:32');

-- --------------------------------------------------------

--
-- Table structure for table `question_comments`
--

CREATE TABLE `question_comments` (
  `comment_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `vetter_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `content_tag` varchar(100) DEFAULT NULL,
  `taxonomy_tag` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `verdict` enum('APPROVED','NEEDS_REVISION','REJECTED') DEFAULT NULL,
  `suggested_taxonomy` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `question_comments`
--

INSERT INTO `question_comments` (`comment_id`, `question_id`, `vetter_id`, `comment_text`, `content_tag`, `taxonomy_tag`, `created_at`, `updated_at`, `verdict`, `suggested_taxonomy`) VALUES
(1, 1, 2, 'The distractors in this question are too obvious. Consider making options B and C closer to the correct answer to better test student comprehension.', 'Needs Revision', 'Appropriate', '2026-07-01 22:44:26', '2026-07-01 22:44:26', '', NULL),
(2, 1, 6, 'I agree with Ali. The question is a bit too easy for a final exam. Please revise the distractors.', 'Needs Revision', 'Appropriate', '2026-07-01 22:44:26', '2026-07-01 22:44:26', '', NULL),
(3, 2, 2, 'Good question, accurately maps to the stated CLO. No changes needed.', 'Appropriate', 'Appropriate', '2026-07-01 22:44:26', '2026-07-01 22:44:26', '', NULL),
(4, 3, 6, 'The taxonomy level seems off here. It is listed as C2 (Understand), but the question requires students to analyze the vulnerability, which is at least C4.', 'Appropriate', 'Needs Revision', '2026-07-01 22:44:26', '2026-07-01 22:44:26', '', 'C4');

-- --------------------------------------------------------

--
-- Table structure for table `question_parts`
--

CREATE TABLE `question_parts` (
  `part_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `part_label` varchar(10) NOT NULL,
  `part_question_text` text DEFAULT NULL,
  `part_marks` int(11) DEFAULT NULL,
  `part_model_answer` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rubric_rows`
--

CREATE TABLE `rubric_rows` (
  `rubric_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `row_order` int(11) NOT NULL DEFAULT 1,
  `criterion` varchar(200) NOT NULL,
  `marks` int(11) NOT NULL DEFAULT 0,
  `clo` varchar(20) DEFAULT NULL,
  `bloom` varchar(10) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rubric_rows`
--

INSERT INTO `rubric_rows` (`rubric_id`, `paper_id`, `row_order`, `criterion`, `marks`, `clo`, `bloom`, `description`) VALUES
(1, 7, 1, 'Introduction & Scope', 30, 'CLO1', 'C3', 'Clear introduction of the project scope and objectives.'),
(2, 7, 2, 'Risk Management Plan', 40, 'CLO2', 'C4', 'Comprehensive identification of risks and mitigation strategies.'),
(3, 7, 3, 'Gantt Chart & Timeline', 30, 'CLO3', 'C5', 'Realistic and detailed project timeline.'),
(7, 8, 1, 'Executive Summary & Scope', 20, 'CLO1', 'C2', 'Clear, concise summary of the assessment scope, objectives, and high-level findings. Excellent articulation for a non-technical audience.'),
(8, 8, 2, 'Methodology & Tool Usage', 30, 'CLO2', 'C4', 'Accurate and effective use of vulnerability scanning tools. Logical and well-documented approach to network mapping and enumeration.'),
(9, 8, 3, 'Vulnerability Findings & Analysis', 30, 'CLO3', 'C5', 'In-depth analysis of discovered vulnerabilities with accurate CVSS scoring and realistic impact assessment.'),
(10, 8, 4, 'Mitigation Recommendations', 20, 'CLO3', 'C6', 'Practical, actionable remediation steps tailored to the specific vulnerabilities found. Professional report formatting.'),
(11, 9, 1, 'Content', 40, NULL, 'C1', ''),
(12, 9, 2, 'Presentation', 30, NULL, 'C2', ''),
(13, 9, 3, 'Report Format', 30, NULL, 'C1', ''),
(14, 10, 1, 'Content', 40, NULL, 'C1', ''),
(15, 10, 2, 'Presentation', 30, NULL, 'C2', ''),
(16, 10, 3, 'Report Format', 30, NULL, 'C1', '');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `phoneNo` varchar(20) DEFAULT NULL,
  `faculty` varchar(150) DEFAULT NULL,
  `position_title` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password_hash`, `role`, `created_at`, `phoneNo`, `faculty`, `position_title`) VALUES
(2, 'Ali', 'ali@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Vetter', '2026-01-21 21:40:56', '013456789012', NULL, NULL),
(3, 'ahmad', 'ahmad@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Lecturer', '2026-01-22 00:05:07', NULL, NULL, NULL),
(5, 'khadijah', 'khadijah@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Lecturer', '2026-01-22 04:34:33', '01234567890', NULL, NULL),
(6, 'Muhammad Syamel', 'syamel@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Vetter', '2026-04-07 03:58:32', NULL, NULL, NULL),
(7, 'Abu Mutalib', 'abu@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'KP', '2026-04-20 23:25:16', NULL, NULL, NULL),
(8, 'shukri', 'shukri@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Lecturer', '2026-06-01 14:34:18', '0123456789', NULL, NULL),
(9, 'aisyah', 'aisyah@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Lecturer', '2026-06-01 14:38:04', '0123456788', NULL, NULL),
(10, 'Najihah', 'najihah@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Lecturer', '2026-07-01 18:47:42', NULL, NULL, NULL),
(11, 'Dr Aminah', 'aminah@umt.edu.my', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Vetter', '2026-07-01 18:47:42', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vetting_checklist`
--

CREATE TABLE `vetting_checklist` (
  `id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `vetter_id` int(11) NOT NULL,
  `section` varchar(20) NOT NULL,
  `ref_id` int(11) DEFAULT NULL,
  `criterion_key` varchar(100) NOT NULL,
  `is_ok` tinyint(1) NOT NULL DEFAULT 0,
  `comment` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vetting_checklist`
--

INSERT INTO `vetting_checklist` (`id`, `paper_id`, `vetter_id`, `section`, `ref_id`, `criterion_key`, `is_ok`, `comment`, `updated_at`) VALUES
(1, 4, 6, 'QUESTION', 20, 'q_content', 1, '', '2026-06-16 03:36:02'),
(2, 4, 6, 'QUESTION', 20, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(3, 4, 6, 'QUESTION', 20, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(4, 4, 6, 'QUESTION', 20, 'q_taxonomy', 0, 'C2 (Understand) is too low for a final exam question. Should be at least C3 (Apply) ù student should be able to identify MitM in a scenario, not just define it.', '2026-06-16 03:36:02'),
(5, 4, 6, 'QUESTION', 20, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(6, 4, 6, 'QUESTION', 21, 'q_content', 1, '', '2026-06-16 03:36:02'),
(7, 4, 6, 'QUESTION', 21, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(8, 4, 6, 'QUESTION', 21, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(9, 4, 6, 'QUESTION', 21, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(10, 4, 6, 'QUESTION', 21, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(11, 4, 6, 'QUESTION', 22, 'q_content', 1, '', '2026-06-16 03:36:02'),
(12, 4, 6, 'QUESTION', 22, 'q_clarity', 0, 'Question stem says \"classified as\" which is ambiguous. Recommend rephrasing to \"Which of the following is an example of an asymmetric encryption algorithm?\"', '2026-06-16 03:36:02'),
(13, 4, 6, 'QUESTION', 22, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(14, 4, 6, 'QUESTION', 22, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(15, 4, 6, 'QUESTION', 22, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(16, 4, 6, 'QUESTION', 23, 'q_content', 1, '', '2026-06-16 03:36:02'),
(17, 4, 6, 'QUESTION', 23, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(18, 4, 6, 'QUESTION', 23, 'q_marks', 0, '18 marks for 3 phases is only 6 marks each. Given the depth expected at C3 level, recommend increasing to 24 marks (8 per phase) or reducing to 2 phases.', '2026-06-16 03:36:02'),
(19, 4, 6, 'QUESTION', 23, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(20, 4, 6, 'QUESTION', 23, 'q_answer', 0, 'Model answer does not specify the marking rubric per sub-point. Examiner needs to know how marks are split within each phase (e.g. 3m definition + 3m tool).', '2026-06-16 03:36:02'),
(21, 4, 6, 'QUESTION', 24, 'q_content', 1, '', '2026-06-16 03:36:02'),
(22, 4, 6, 'QUESTION', 24, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(23, 4, 6, 'QUESTION', 24, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(24, 4, 6, 'QUESTION', 24, 'q_taxonomy', 1, 'C5 (Evaluate) is appropriate for this case-study question.', '2026-06-16 03:36:02'),
(25, 4, 6, 'QUESTION', 24, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(26, 4, 6, 'JSS', NULL, 'jss_coverage', 1, '', '2026-06-16 03:36:02'),
(27, 4, 6, 'JSS', NULL, 'jss_bloom', 0, 'Bloom distribution is skewed ù 70 marks at C5, only 12 marks at C1-C2. Recommend adding one more mid-level (C3/C4) question to balance the distribution.', '2026-06-16 03:36:02'),
(28, 4, 6, 'JSS', NULL, 'jss_weights', 1, '', '2026-06-16 03:36:02'),
(29, 4, 6, 'JSS', NULL, 'jss_format', 1, '', '2026-06-16 03:36:02'),
(30, 4, 6, 'SCHEME', NULL, 'sc_complete', 1, '', '2026-06-16 03:36:02'),
(31, 4, 6, 'SCHEME', NULL, 'sc_marking', 0, 'Q4 model answer does not break down marks per sub-point. Needs explicit mark allocation e.g. (3m + 3m) per phase.', '2026-06-16 03:36:02'),
(32, 4, 6, 'SCHEME', NULL, 'sc_partial', 0, 'No guidance on awarding partial marks for Q5. Candidate may give a correct but incomplete IR plan ù examiner needs a floor mark.', '2026-06-16 03:36:02'),
(33, 4, 6, 'SCHEME', NULL, 'sc_consistent', 1, '', '2026-06-16 03:36:02'),
(34, 4, 2, 'QUESTION', 20, 'q_content', 1, '', '2026-06-16 03:36:02'),
(35, 4, 2, 'QUESTION', 20, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(36, 4, 2, 'QUESTION', 20, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(37, 4, 2, 'QUESTION', 20, 'q_taxonomy', 0, 'Agree with leader vetter ù C2 is too low for final examination.', '2026-06-16 03:36:02'),
(38, 4, 2, 'QUESTION', 20, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(39, 4, 2, 'QUESTION', 21, 'q_content', 1, '', '2026-06-16 03:36:02'),
(40, 4, 2, 'QUESTION', 21, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(41, 4, 2, 'QUESTION', 21, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(42, 4, 2, 'QUESTION', 21, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(43, 4, 2, 'QUESTION', 21, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(44, 4, 2, 'QUESTION', 22, 'q_content', 1, '', '2026-06-16 03:36:02'),
(45, 4, 2, 'QUESTION', 22, 'q_clarity', 1, 'Minor wording issue but acceptable.', '2026-06-16 03:36:02'),
(46, 4, 2, 'QUESTION', 22, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(47, 4, 2, 'QUESTION', 22, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(48, 4, 2, 'QUESTION', 22, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(49, 4, 2, 'QUESTION', 23, 'q_content', 1, '', '2026-06-16 03:36:02'),
(50, 4, 2, 'QUESTION', 23, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(51, 4, 2, 'QUESTION', 23, 'q_marks', 0, 'Marks seem low relative to the answer length expected. Consider 24 marks.', '2026-06-16 03:36:02'),
(52, 4, 2, 'QUESTION', 23, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(53, 4, 2, 'QUESTION', 23, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(54, 4, 2, 'QUESTION', 24, 'q_content', 1, '', '2026-06-16 03:36:02'),
(55, 4, 2, 'QUESTION', 24, 'q_clarity', 1, '', '2026-06-16 03:36:02'),
(56, 4, 2, 'QUESTION', 24, 'q_marks', 1, '', '2026-06-16 03:36:02'),
(57, 4, 2, 'QUESTION', 24, 'q_taxonomy', 1, '', '2026-06-16 03:36:02'),
(58, 4, 2, 'QUESTION', 24, 'q_answer', 1, '', '2026-06-16 03:36:02'),
(59, 4, 2, 'JSS', NULL, 'jss_coverage', 1, '', '2026-06-16 03:36:02'),
(60, 4, 2, 'JSS', NULL, 'jss_bloom', 0, 'Heavy weighting on C5. Suggest adding a C4 question.', '2026-06-16 03:36:02'),
(61, 4, 2, 'JSS', NULL, 'jss_weights', 1, '', '2026-06-16 03:36:02'),
(62, 4, 2, 'JSS', NULL, 'jss_format', 1, '', '2026-06-16 03:36:02'),
(63, 4, 2, 'SCHEME', NULL, 'sc_complete', 1, '', '2026-06-16 03:36:02'),
(64, 4, 2, 'SCHEME', NULL, 'sc_marking', 1, '', '2026-06-16 03:36:02'),
(65, 4, 2, 'SCHEME', NULL, 'sc_partial', 0, 'Partial mark guidance missing for Q5 essay.', '2026-06-16 03:36:02'),
(66, 4, 2, 'SCHEME', NULL, 'sc_consistent', 1, '', '2026-06-16 03:36:02'),
(67, 5, 6, 'QUESTION', 25, 'q_content', 1, '', '2026-06-16 05:05:42'),
(68, 5, 6, 'QUESTION', 25, 'q_clarity', 1, '', '2026-06-16 05:05:42'),
(69, 5, 6, 'QUESTION', 25, 'q_taxonomy', 1, '', '2026-06-16 05:05:42'),
(70, 5, 6, 'QUESTION', 25, 'q_marks', 1, '', '2026-06-16 05:05:42'),
(71, 5, 6, 'QUESTION', 25, 'q_answer', 1, '', '2026-06-16 05:05:42'),
(72, 5, 6, 'QUESTION', 26, 'q_content', 1, '', '2026-06-16 05:05:42'),
(73, 5, 6, 'QUESTION', 26, 'q_clarity', 1, '', '2026-06-16 05:05:42'),
(74, 5, 6, 'QUESTION', 26, 'q_taxonomy', 0, 'C2 (Comprehension) seems appropriate but question wording leans more towards C1 recall. Consider revising stem to require application of the principle.', '2026-06-16 05:05:42'),
(75, 5, 6, 'QUESTION', 26, 'q_marks', 1, '', '2026-06-16 05:05:42'),
(76, 5, 6, 'QUESTION', 26, 'q_answer', 1, '', '2026-06-16 05:05:42'),
(77, 5, 6, 'QUESTION', 27, 'q_content', 1, '', '2026-06-16 05:05:42'),
(78, 5, 6, 'QUESTION', 27, 'q_clarity', 1, '', '2026-06-16 05:05:42'),
(79, 5, 6, 'QUESTION', 27, 'q_taxonomy', 1, '', '2026-06-16 05:05:42'),
(80, 5, 6, 'QUESTION', 27, 'q_marks', 1, '', '2026-06-16 05:05:42'),
(81, 5, 6, 'QUESTION', 27, 'q_answer', 1, '', '2026-06-16 05:05:42'),
(82, 5, 6, 'QUESTION', 28, 'q_content', 1, '', '2026-06-16 05:05:42'),
(83, 5, 6, 'QUESTION', 28, 'q_clarity', 0, 'Option C (Application layer gateway) and Option D (Proxy firewall) are very similar concepts; may confuse students. Recommend differentiating the distractors more clearly.', '2026-06-16 05:05:42'),
(84, 5, 6, 'QUESTION', 28, 'q_taxonomy', 1, '', '2026-06-16 05:05:42'),
(85, 5, 6, 'QUESTION', 28, 'q_marks', 1, '', '2026-06-16 05:05:42'),
(86, 5, 6, 'QUESTION', 28, 'q_answer', 1, '', '2026-06-16 05:05:42'),
(87, 5, 6, 'QUESTION', 29, 'q_content', 1, '', '2026-06-16 05:05:42'),
(88, 5, 6, 'QUESTION', 29, 'q_clarity', 1, '', '2026-06-16 05:05:42'),
(89, 5, 6, 'QUESTION', 29, 'q_taxonomy', 1, '', '2026-06-16 05:05:42'),
(90, 5, 6, 'QUESTION', 29, 'q_marks', 0, '34 marks for a structure question in a 50-mark paper is disproportionate (68%). Recommend redistributing to 20 marks maximum.', '2026-06-16 05:05:42'),
(91, 5, 6, 'QUESTION', 29, 'q_answer', 0, 'Model answer does not include a marking rubric breakdown. Please provide per-part marks allocation (a) and (b) clearly.', '2026-06-16 05:05:42'),
(92, 5, 6, 'JSS', NULL, 'jss_bloom', 1, '', '2026-06-16 05:05:42'),
(93, 5, 6, 'JSS', NULL, 'jss_clo', 1, '', '2026-06-16 05:05:42'),
(94, 5, 6, 'JSS', NULL, 'jss_marks', 0, 'Total marks distribution is skewed. Q5 carries too much weight relative to objectives. Suggest balancing before approval.', '2026-06-16 05:05:42'),
(95, 5, 6, 'JSS', NULL, 'jss_coverage', 1, '', '2026-06-16 05:05:42'),
(96, 5, 6, 'SCHEME', NULL, 'scheme_complete', 1, '', '2026-06-16 05:05:42'),
(97, 5, 6, 'SCHEME', NULL, 'scheme_partial', 0, 'No partial marking guidance provided for Q5(b). Students who correctly identify one prevention measure but not both should receive partial credit.', '2026-06-16 05:05:42'),
(98, 5, 6, 'SCHEME', NULL, 'scheme_rubric', 0, 'Rubric for Q5 essay component is absent. A band descriptor (excellent/good/satisfactory/poor) is required per faculty guidelines.', '2026-06-16 05:05:42'),
(99, 5, 6, 'SCHEME', NULL, 'scheme_answer', 1, '', '2026-06-16 05:05:42'),
(100, 6, 6, 'QUESTION', 30, 'q_content', 1, '', '2026-06-16 05:43:32'),
(101, 6, 6, 'QUESTION', 30, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(102, 6, 6, 'QUESTION', 30, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(103, 6, 6, 'QUESTION', 30, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(104, 6, 6, 'QUESTION', 30, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(105, 6, 6, 'QUESTION', 31, 'q_content', 1, '', '2026-06-16 05:43:32'),
(106, 6, 6, 'QUESTION', 31, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(107, 6, 6, 'QUESTION', 31, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(108, 6, 6, 'QUESTION', 31, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(109, 6, 6, 'QUESTION', 31, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(110, 6, 6, 'QUESTION', 32, 'q_content', 1, '', '2026-06-16 05:43:32'),
(111, 6, 6, 'QUESTION', 32, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(112, 6, 6, 'QUESTION', 32, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(113, 6, 6, 'QUESTION', 32, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(114, 6, 6, 'QUESTION', 32, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(115, 6, 6, 'QUESTION', 33, 'q_content', 1, '', '2026-06-16 05:43:32'),
(116, 6, 6, 'QUESTION', 33, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(117, 6, 6, 'QUESTION', 33, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(118, 6, 6, 'QUESTION', 33, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(119, 6, 6, 'QUESTION', 33, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(120, 6, 6, 'QUESTION', 34, 'q_content', 1, '', '2026-06-16 05:43:32'),
(121, 6, 6, 'QUESTION', 34, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(122, 6, 6, 'QUESTION', 34, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(123, 6, 6, 'QUESTION', 34, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(124, 6, 6, 'QUESTION', 34, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(125, 6, 6, 'JSS', NULL, 'jss_bloom', 1, '', '2026-06-16 05:43:32'),
(126, 6, 6, 'JSS', NULL, 'jss_clo', 1, '', '2026-06-16 05:43:32'),
(127, 6, 6, 'JSS', NULL, 'jss_marks', 1, '', '2026-06-16 05:43:32'),
(128, 6, 6, 'JSS', NULL, 'jss_coverage', 1, '', '2026-06-16 05:43:32'),
(129, 6, 6, 'SCHEME', NULL, 'scheme_complete', 1, '', '2026-06-16 05:43:32'),
(130, 6, 6, 'SCHEME', NULL, 'scheme_partial', 1, '', '2026-06-16 05:43:32'),
(131, 6, 6, 'SCHEME', NULL, 'scheme_rubric', 1, '', '2026-06-16 05:43:32'),
(132, 6, 6, 'SCHEME', NULL, 'scheme_answer', 1, '', '2026-06-16 05:43:32'),
(133, 6, 2, 'QUESTION', 30, 'q_content', 1, '', '2026-06-16 05:43:32'),
(134, 6, 2, 'QUESTION', 30, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(135, 6, 2, 'QUESTION', 30, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(136, 6, 2, 'QUESTION', 30, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(137, 6, 2, 'QUESTION', 30, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(138, 6, 2, 'QUESTION', 31, 'q_content', 1, '', '2026-06-16 05:43:32'),
(139, 6, 2, 'QUESTION', 31, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(140, 6, 2, 'QUESTION', 31, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(141, 6, 2, 'QUESTION', 31, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(142, 6, 2, 'QUESTION', 31, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(143, 6, 2, 'QUESTION', 32, 'q_content', 1, '', '2026-06-16 05:43:32'),
(144, 6, 2, 'QUESTION', 32, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(145, 6, 2, 'QUESTION', 32, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(146, 6, 2, 'QUESTION', 32, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(147, 6, 2, 'QUESTION', 32, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(148, 6, 2, 'QUESTION', 33, 'q_content', 1, '', '2026-06-16 05:43:32'),
(149, 6, 2, 'QUESTION', 33, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(150, 6, 2, 'QUESTION', 33, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(151, 6, 2, 'QUESTION', 33, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(152, 6, 2, 'QUESTION', 33, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(153, 6, 2, 'QUESTION', 34, 'q_content', 1, '', '2026-06-16 05:43:32'),
(154, 6, 2, 'QUESTION', 34, 'q_clarity', 1, '', '2026-06-16 05:43:32'),
(155, 6, 2, 'QUESTION', 34, 'q_taxonomy', 1, '', '2026-06-16 05:43:32'),
(156, 6, 2, 'QUESTION', 34, 'q_marks', 1, '', '2026-06-16 05:43:32'),
(157, 6, 2, 'QUESTION', 34, 'q_answer', 1, '', '2026-06-16 05:43:32'),
(158, 6, 2, 'JSS', NULL, 'jss_bloom', 1, '', '2026-06-16 05:43:32'),
(159, 6, 2, 'JSS', NULL, 'jss_clo', 1, '', '2026-06-16 05:43:32'),
(160, 6, 2, 'JSS', NULL, 'jss_marks', 1, '', '2026-06-16 05:43:32'),
(161, 6, 2, 'JSS', NULL, 'jss_coverage', 1, '', '2026-06-16 05:43:32'),
(162, 6, 2, 'SCHEME', NULL, 'scheme_complete', 1, '', '2026-06-16 05:43:32'),
(163, 6, 2, 'SCHEME', NULL, 'scheme_partial', 1, '', '2026-06-16 05:43:32'),
(164, 6, 2, 'SCHEME', NULL, 'scheme_rubric', 1, '', '2026-06-16 05:43:32'),
(165, 6, 2, 'SCHEME', NULL, 'scheme_answer', 1, '', '2026-06-16 05:43:32');

-- --------------------------------------------------------

--
-- Table structure for table `vetting_forms`
--

CREATE TABLE `vetting_forms` (
  `form_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL,
  `form_type` enum('FAP01a','FAP01b') NOT NULL DEFAULT 'FAP01a',
  `created_by` int(11) NOT NULL,
  `programme` varchar(200) DEFAULT NULL,
  `eq_code1` varchar(50) DEFAULT NULL,
  `eq_name1` varchar(200) DEFAULT NULL,
  `eq_code2` varchar(50) DEFAULT NULL,
  `eq_name2` varchar(200) DEFAULT NULL,
  `eq_code3` varchar(50) DEFAULT NULL,
  `eq_name3` varchar(200) DEFAULT NULL,
  `credit_hours` decimal(3,1) DEFAULT NULL,
  `total_students` int(11) DEFAULT NULL,
  `num_objective` int(11) DEFAULT 0,
  `num_structure` int(11) DEFAULT 0,
  `num_essay` int(11) DEFAULT 0,
  `total_to_answer` int(11) DEFAULT 0,
  `exam_duration` varchar(50) DEFAULT NULL,
  `assessment_type_desc` varchar(300) DEFAULT NULL,
  `weightage_percent` decimal(5,2) DEFAULT NULL,
  `task_duration` varchar(100) DEFAULT NULL,
  `clo_data` text DEFAULT NULL,
  `section_b_data` text DEFAULT NULL,
  `section_c_data` text DEFAULT NULL,
  `overall_remarks` text DEFAULT NULL,
  `vetter_name` varchar(200) DEFAULT NULL,
  `vetter_date` varchar(30) DEFAULT NULL,
  `lecturer_sign_name` varchar(200) DEFAULT NULL,
  `lecturer_sign_date` varchar(30) DEFAULT NULL,
  `head_vetter_name` varchar(200) DEFAULT NULL,
  `head_vetter_date` varchar(30) DEFAULT NULL,
  `is_improved` tinyint(1) DEFAULT 0,
  `improvement_justification` text DEFAULT NULL,
  `improvement_elaboration` text DEFAULT NULL,
  `form_status` enum('DRAFT','SUBMITTED') DEFAULT 'DRAFT',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`course_id`),
  ADD UNIQUE KEY `course_code` (`course_code`),
  ADD KEY `lecturer_id` (`lecturer_id`),
  ADD KEY `vetter_id` (`vetter_id`);

--
-- Indexes for table `course_information`
--
ALTER TABLE `course_information`
  ADD PRIMARY KEY (`course_id`);

--
-- Indexes for table `course_vetters`
--
ALTER TABLE `course_vetters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cv` (`course_id`,`vetter_id`),
  ADD KEY `fk_cv_vetter` (`vetter_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `exam_papers`
--
ALTER TABLE `exam_papers`
  ADD PRIMARY KEY (`paper_id`),
  ADD KEY `fk_paper_lecturer` (`lecturer_id`),
  ADD KEY `fk_paper_ketua_panel` (`ketua_panel_id`),
  ADD KEY `fk_paper_ketua_program` (`ketua_program_id`);

--
-- Indexes for table `jss`
--
ALTER TABLE `jss`
  ADD PRIMARY KEY (`jss_id`),
  ADD UNIQUE KEY `paper_id` (`paper_id`),
  ADD KEY `fk_jss_lecturer` (`lecturer_id`);

--
-- Indexes for table `jss_rows`
--
ALTER TABLE `jss_rows`
  ADD PRIMARY KEY (`row_id`),
  ADD KEY `fk_jr_jss` (`jss_id`);

--
-- Indexes for table `lecturer_courses`
--
ALTER TABLE `lecturer_courses`
  ADD PRIMARY KEY (`lecturer_id`,`course_id`),
  ADD KEY `fk_lc_course` (`course_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_paper` (`paper_id`);

--
-- Indexes for table `message_reads`
--
ALTER TABLE `message_reads`
  ADD PRIMARY KEY (`user_id`,`paper_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `paper_section_comments`
--
ALTER TABLE `paper_section_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_paper_section` (`paper_id`,`section`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `fk_question_paper` (`paper_id`);

--
-- Indexes for table `question_comments`
--
ALTER TABLE `question_comments`
  ADD PRIMARY KEY (`comment_id`),
  ADD UNIQUE KEY `uq_question_vetter` (`question_id`,`vetter_id`),
  ADD KEY `fk_qc_vetter` (`vetter_id`);

--
-- Indexes for table `question_parts`
--
ALTER TABLE `question_parts`
  ADD PRIMARY KEY (`part_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `rubric_rows`
--
ALTER TABLE `rubric_rows`
  ADD PRIMARY KEY (`rubric_id`),
  ADD KEY `fk_rubric_paper` (`paper_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vetting_checklist`
--
ALTER TABLE `vetting_checklist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_vcl` (`paper_id`,`vetter_id`,`section`,`ref_id`,`criterion_key`);

--
-- Indexes for table `vetting_forms`
--
ALTER TABLE `vetting_forms`
  ADD PRIMARY KEY (`form_id`),
  ADD KEY `paper_id` (`paper_id`),
  ADD KEY `created_by` (`created_by`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `course`
--
ALTER TABLE `course`
  MODIFY `course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `course_vetters`
--
ALTER TABLE `course_vetters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `exam_papers`
--
ALTER TABLE `exam_papers`
  MODIFY `paper_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `jss`
--
ALTER TABLE `jss`
  MODIFY `jss_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `jss_rows`
--
ALTER TABLE `jss_rows`
  MODIFY `row_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `paper_section_comments`
--
ALTER TABLE `paper_section_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `question_comments`
--
ALTER TABLE `question_comments`
  MODIFY `comment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `question_parts`
--
ALTER TABLE `question_parts`
  MODIFY `part_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rubric_rows`
--
ALTER TABLE `rubric_rows`
  MODIFY `rubric_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `vetting_checklist`
--
ALTER TABLE `vetting_checklist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=166;

--
-- AUTO_INCREMENT for table `vetting_forms`
--
ALTER TABLE `vetting_forms`
  MODIFY `form_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `course_ibfk_2` FOREIGN KEY (`vetter_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `course_information`
--
ALTER TABLE `course_information`
  ADD CONSTRAINT `course_information_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_vetters`
--
ALTER TABLE `course_vetters`
  ADD CONSTRAINT `fk_cv_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cv_vetter` FOREIGN KEY (`vetter_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `events_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `exam_papers`
--
ALTER TABLE `exam_papers`
  ADD CONSTRAINT `fk_paper_ketua_panel` FOREIGN KEY (`ketua_panel_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_paper_ketua_program` FOREIGN KEY (`ketua_program_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_paper_lecturer` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `jss`
--
ALTER TABLE `jss`
  ADD CONSTRAINT `fk_jss_lecturer` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_jss_paper` FOREIGN KEY (`paper_id`) REFERENCES `exam_papers` (`paper_id`) ON DELETE CASCADE;

--
-- Constraints for table `jss_rows`
--
ALTER TABLE `jss_rows`
  ADD CONSTRAINT `fk_jr_jss` FOREIGN KEY (`jss_id`) REFERENCES `jss` (`jss_id`) ON DELETE CASCADE;

--
-- Constraints for table `lecturer_courses`
--
ALTER TABLE `lecturer_courses`
  ADD CONSTRAINT `fk_lc_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_lc_lecturer` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_question_paper` FOREIGN KEY (`paper_id`) REFERENCES `exam_papers` (`paper_id`) ON DELETE CASCADE;

--
-- Constraints for table `question_comments`
--
ALTER TABLE `question_comments`
  ADD CONSTRAINT `fk_qc_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_qc_vetter` FOREIGN KEY (`vetter_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `question_parts`
--
ALTER TABLE `question_parts`
  ADD CONSTRAINT `question_parts_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `rubric_rows`
--
ALTER TABLE `rubric_rows`
  ADD CONSTRAINT `fk_rubric_paper` FOREIGN KEY (`paper_id`) REFERENCES `exam_papers` (`paper_id`) ON DELETE CASCADE;

--
-- Constraints for table `vetting_forms`
--
ALTER TABLE `vetting_forms`
  ADD CONSTRAINT `vetting_forms_ibfk_1` FOREIGN KEY (`paper_id`) REFERENCES `exam_papers` (`paper_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vetting_forms_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
