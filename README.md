# kavach

A new Flutter project.


CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE EmergencyContacts (
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    friend_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'unverified',  -- Can be unverified, verified
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, friend_id)
);

CREATE TABLE Clusters (
    cluster_id SERIAL PRIMARY KEY,
    cluster_type VARCHAR(10)  -- Different types of incidents
);

CREATE TABLE Incidents (
    incident_id SERIAL PRIMARY KEY,
    cluster_id INT REFERENCES Clusters(cluster_id),
    incident_type VARCHAR(50),  -- e.g., 'Social Harassment', 'Sexual Harassment', etc.
    description TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    similar_reports INT[],  -- Array of incident_ids
    genuinity INT CHECK(genuinity BETWEEN 1 AND 5),
    status VARCHAR(20) DEFAULT 'active'  -- Can be 'active', 'decayed', 'resolved'
);

CREATE TABLE PastJourneys (
    journey_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    incident_identified INT REFERENCES Incidents(incident_id)
);

CREATE TABLE Journey (
    journey_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    start_location DOUBLE PRECISION NOT NULL,
    end_location DOUBLE PRECISION NOT NULL,
    current_x DOUBLE PRECISION NOT NULL,
    current_y DOUBLE PRECISION NOT NULL,
    added_context TEXT NULL,
    time_to_reach TIMESTAMP NOT NULL
);

CREATE TABLE JourneyNumber (
    journey_id INT,
    phone_numbers VARCHAR(20),
    name VARCHAR(100),
    FOREIGN KEY (journey_id) REFERENCES Journey(journey_id)
);




create policy "public can read clusters"
on public.clusters
for select to anon
using (true);

create policy "public can read emergencycontacts"
on public.emergencycontacts
for select to anon
using (true);

create policy "public can read pastjourneys"
on public.pastjourneys
for select to anon
using (true);

create policy "public can read incidents"
on public.incidents
for select to anon
using (true);

create policy "public can read journey"
on public.journey
for select to anon
using (true);

create policy "public can read journeynumber"
on public.journeynumber
for select to anon
using (true);