SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS files, activity_logs, feedback, meetings, tasks, milestones, projects, users, clients, agencies;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE agencies (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(150) NOT NULL, owner_name VARCHAR(120) NOT NULL,
 contact_email VARCHAR(190) NOT NULL, phone VARCHAR(40), status ENUM('active','suspended') NOT NULL DEFAULT 'active',
 plan VARCHAR(40) NOT NULL DEFAULT 'trial', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_agency_status(status), INDEX idx_agency_name(name)
);
CREATE TABLE clients (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, company_name VARCHAR(150) NOT NULL,
 contact_name VARCHAR(120) NOT NULL, email VARCHAR(190), phone VARCHAR(40), notes TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE,
 UNIQUE KEY uq_client_agency(id,agency_id), INDEX idx_clients_agency(agency_id)
);
CREATE TABLE users (
 id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(190) NOT NULL UNIQUE, password_hash VARCHAR(100) NOT NULL,
 name VARCHAR(120) NOT NULL, role ENUM('super_admin','agency_admin','agency_member','client') NOT NULL,
 agency_id INT NULL, client_id INT NULL, is_active TINYINT(1) NOT NULL DEFAULT 1, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE,
 FOREIGN KEY(client_id,agency_id) REFERENCES clients(id,agency_id) ON DELETE CASCADE,
 INDEX idx_users_agency(agency_id), INDEX idx_users_role(role)
);
CREATE TABLE projects (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, client_id INT NOT NULL, manager_id INT NULL,
 name VARCHAR(150) NOT NULL, description TEXT, status ENUM('active','on_hold','completed') NOT NULL DEFAULT 'active',
 priority ENUM('low','medium','high') NOT NULL DEFAULT 'medium', start_date DATE, due_date DATE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE,
 FOREIGN KEY(client_id,agency_id) REFERENCES clients(id,agency_id),
 FOREIGN KEY(manager_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_projects_tenant(agency_id,status), INDEX idx_projects_due(agency_id,due_date)
);
CREATE TABLE milestones (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, project_id INT NOT NULL, title VARCHAR(150) NOT NULL,
 status ENUM('planned','in_progress','completed') DEFAULT 'planned', due_date DATE,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE,
 INDEX idx_milestone_project(agency_id,project_id)
);
CREATE TABLE tasks (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, project_id INT NOT NULL, milestone_id INT NULL, assignee_id INT NULL,
 title VARCHAR(180) NOT NULL, description TEXT, status ENUM('todo','in_progress','done') DEFAULT 'todo',
 priority ENUM('low','medium','high') DEFAULT 'medium', due_date DATE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE,
 FOREIGN KEY(milestone_id) REFERENCES milestones(id) ON DELETE SET NULL, FOREIGN KEY(assignee_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_tasks_project(agency_id,project_id,status), INDEX idx_tasks_assignee(agency_id,assignee_id)
);
CREATE TABLE meetings (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, project_id INT NOT NULL, title VARCHAR(180) NOT NULL,
 meeting_date DATETIME NOT NULL, notes TEXT, client_visible TINYINT(1) DEFAULT 0, created_by INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE,
 FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE, FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_meetings_project(agency_id,project_id,meeting_date)
);
CREATE TABLE feedback (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, project_id INT NOT NULL, client_id INT NOT NULL, submitted_by INT NOT NULL,
 title VARCHAR(180) NOT NULL, description TEXT NOT NULL, status ENUM('open','in_review','in_progress','resolved','declined') DEFAULT 'open',
 agency_response TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE,
 FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE, FOREIGN KEY(submitted_by) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_feedback_project(agency_id,project_id,status)
);
CREATE TABLE files (
 id INT AUTO_INCREMENT PRIMARY KEY, agency_id INT NOT NULL, project_id INT NOT NULL, task_id INT NULL, feedback_id INT NULL,
 uploaded_by INT NOT NULL, original_name VARCHAR(255) NOT NULL, mime_type VARCHAR(120) NOT NULL, size_bytes INT NOT NULL,
 content LONGBLOB NOT NULL, shared_with_client TINYINT(1) DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(agency_id) REFERENCES agencies(id) ON DELETE CASCADE, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE,
 FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE SET NULL, FOREIGN KEY(feedback_id) REFERENCES feedback(id) ON DELETE SET NULL,
 FOREIGN KEY(uploaded_by) REFERENCES users(id) ON DELETE CASCADE, INDEX idx_files_project(agency_id,project_id)
);
CREATE TABLE activity_logs (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, agency_id INT NULL, actor_id INT NULL, event_type VARCHAR(80) NOT NULL,
 entity_type VARCHAR(50), entity_id INT, visibility ENUM('internal','client') DEFAULT 'internal', metadata JSON,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(actor_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_activity_tenant(agency_id,created_at), INDEX idx_activity_visibility(agency_id,visibility,created_at)
);
