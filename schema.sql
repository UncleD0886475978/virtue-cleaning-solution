CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);
INSERT INTO departments (name, description) VALUES
('Residential Cleaning', 'Home and apartment cleaning services'),
('Commercial Cleaning', 'Office and business cleaning services'),
('Operations', 'Scheduling, dispatch, and logistics'),
('Sales & Client Relations', 'New client acquisition and account management');
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(100),
    department_id INTEGER REFERENCES departments(id),
    hire_date DATE,
    email VARCHAR(100)
);
INSERT INTO employees (first_name, last_name, role, department_id, hire_date, email) VALUES
('Maria', 'Gonzalez', 'Lead Cleaner', 1, '2025-03-10', 'maria.g@virtuecleaning.com'),
('James', 'Whitfield', 'Cleaning Technician', 1, '2025-06-01', 'james.w@virtuecleaning.com'),
('Aisha', 'Thompson', 'Commercial Crew Lead', 2, '2025-01-15', 'aisha.t@virtuecleaning.com'),
('Devon', 'Carter', 'Cleaning Technician', 2, '2025-07-22', 'devon.c@virtuecleaning.com'),
('Priya', 'Nair', 'Operations Manager', 3, '2024-11-05', 'priya.n@virtuecleaning.com'),
('Samuel', 'Okafor', 'Dispatch Coordinator', 3, '2025-04-18', 'samuel.o@virtuecleaning.com'),
('Rachel', 'Kim', 'Sales Representative', 4, '2025-02-01', 'rachel.k@virtuecleaning.com');
CREATE TABLE supplies (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(150) NOT NULL,
    category VARCHAR(50),
    unit VARCHAR(30),
    quantity_on_hand INTEGER DEFAULT 0,
    reorder_threshold INTEGER DEFAULT 5,
    unit_cost NUMERIC(8,2)
);
INSERT INTO supplies (item_name, category, unit, quantity_on_hand, reorder_threshold, unit_cost) VALUES
('Commercial Vacuum (Backpack)', 'Equipment', 'unit', 4, 1, 189.99),
('Microfiber Cleaning Cloths', 'Consumable', 'pack of 24', 15, 5, 18.50),
('All-Purpose Cleaner (Gallon)', 'Chemical', 'gallon', 20, 6, 12.75),
('Glass Cleaner (Gallon)', 'Chemical', 'gallon', 10, 4, 11.25),
('Disinfectant Spray', 'Chemical', 'bottle', 30, 10, 6.99),
('Mop Buckets w/ Wringer', 'Equipment', 'unit', 6, 2, 42.00),
('Flat Mops', 'Equipment', 'unit', 12, 4, 24.99),
('Rubber Gloves', 'Consumable', 'box of 100', 8, 3, 9.99),
('Trash Bags (Heavy Duty)', 'Consumable', 'box', 25, 8, 14.50),
('Floor Scrubber (Commercial)', 'Equipment', 'unit', 2, 1, 649.00),
('Carpet Extractor', 'Equipment', 'unit', 1, 1, 899.00),
('Restroom Cleaning Kit', 'Chemical', 'kit', 10, 5, 22.00);
