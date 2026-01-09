# Nyaya Connect: Justice Delivered Digitally

Nyaya Connect is a **mobile-first digital legal assistance and e-justice platform** designed to improve **accessibility, transparency, and efficiency** in legal service delivery. The platform bridges the gap between **citizens, lawyers, NGOs, and legal institutions** by providing a unified, secure, and scalable digital interface for legal consultations and case management.

This project was developed as a **Final Year B.E. Computer Science & Engineering project** and has been **published as a research paper** in the *International Journal of Scientific Research in Engineering and Management (IJSREM)*.

---

##  Problem Statement

In India, access to legal services remains **fragmented and inefficient**, particularly for rural and economically weaker communities. Small law firms and legal aid NGOs often operate with:

* Inadequate digital infrastructure
* Manual case handling and poor document management
* Limited transparency in case tracking
* Weak communication between lawyers and clients

The absence of a **centralized, secure digital platform** results in delays, reduced trust, and unequal access to justice.

---

##  Objectives

* Develop a **centralized digital platform** connecting citizens, lawyers, and legal aid NGOs
* Provide **AI-powered preliminary legal guidance** to improve legal literacy
* Enable **secure document management** and real-time case tracking
* Reduce dependency on physical visits and intermediaries
* Align with national initiatives such as **Digital India** and the **e-Courts Mission**

---

##  Key Features

*  **Secure User Authentication** using Firebase
*  **Lawyer & NGO Profile Management**
*  **Case Submission & Document Upload**
*  **Real-Time Case Tracking and Status Updates**
*  **Push Notifications & Alerts**
*  **AI Doubt Forum** for preliminary legal guidance
*  **Cloud-based, Scalable Architecture**

---

##  Application Screenshots
### Login & Authentication
<img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/87f5ff59-99cf-466d-8ec2-a4379da03a3b" /> <img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/5a1525bd-69d4-4930-b6ff-d0c837e6dd4f" />

### User Dashboard
<img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/ec3c035f-5e8c-46ce-8e94-c44d0a61966e" />  <img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/21c257d1-f387-41ed-9686-b297be837e9c" />  <img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/58293a39-9895-4188-aca3-51402b79860a" />




### Lawyer Profile & Case Submission
<img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/7097fa03-1bee-4cdb-8edb-36247c92d5c1" />   <img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/4bcb437d-6223-4b6c-ac1e-00f939623615" />  <img width="294" height="439" alt="image" src="https://github.com/user-attachments/assets/04741c99-91a3-4baa-acb5-b2f1db30ff77" />



---

##  System Architecture (High Level)

Nyaya Connect follows a **cloud-based, role-driven architecture**:

* **Frontend:** Flutter (Android-first, mobile-friendly UI)
* **Backend:** Firebase (Authentication, Firestore, Cloud Storage, Cloud Messaging)
* **AI Layer:** AI-based legal query handling and document summarization
* **Database:** Cloud Firestore (NoSQL, real-time synchronization)

All users are routed through **role-based dashboards** (Citizen / Lawyer / Admin) with controlled access and secure data flow.

---

##  Major Modules

### 1. User (Citizen) Module

* Registration & login
* Legal help request submission
* Document upload & viewing
* Case tracking and notifications

### 2. Lawyer / NGO Module

* Profile creation and management
* Accepting/rejecting consultation requests
* Case progress updates
* Secure document access

### 3. AI Doubt Forum

* Preliminary legal guidance
* FAQ-based and query-based assistance
* Improves legal awareness before formal consultation

### 4. Admin Module

* System monitoring
* User and content management
* Platform oversight

---

## 🛠️ Technology Stack

| Layer          | Technology               |
| -------------- | ------------------------ |
| Frontend       | Flutter                  |
| Backend        | Firebase                 |
| Authentication | Firebase Authentication  |
| Database       | Cloud Firestore          |
| Storage        | Firebase Cloud Storage   |
| Notifications  | Firebase Cloud Messaging |
| AI Integration | AI-based NLP models      |
| UI/UX          | Figma                    |

---
# 🏗️ Technical Architecture

## 🖥️ Frontend Stack

- **React.js** – UI framework
- **React Router** – Client-side navigation
- **Axios** – HTTP client
- **Context API / Redux** – State management
- **CSS Modules / Styled Components** – Styling
- **Form Validation Libraries** – Input validation

---

## 🛠️ Backend Stack

- **Node.js** – Runtime environment
- **Express.js** – Web framework
- **MongoDB** – Database
- **Mongoose** – Object Data Modeling (ODM)
- **JWT** – Authentication
- **Multer** – File uploads
- **Bcrypt** – Password hashing
- **Nodemailer** – Email notifications

---

## 🗄️ Database Schema

### 👤 User Model

```javascript
{
  name: String,
  email: String, // unique
  password: String, // hashed
  role: ['citizen', 'lawyer', 'admin'],
  phone: String,
  address: Object,
  createdAt: Date
}
```

### ⚖️ Lawyer Model

``` javascript
{
  userId: ObjectId, // ref: User
  barCouncilId: String,
  specialization: [String],
  experience: Number,
  rating: Number,
  cases: Number,
  availability: Object,
  fees: Object
}

```

### 📁 Case Model

``` javascript
{
  title: String,
  description: String,
  client: ObjectId, // ref: User
  lawyer: ObjectId, // ref: Lawyer
  category: String,
  status: ['pending', 'active', 'closed'],
  documents: [ObjectId],
  timeline: [Object],
  createdAt: Date,
  updatedAt: Date
}

```

### 📄 Document Model

``` javascript
{
  caseId: ObjectId, // ref: Case
  uploadedBy: ObjectId, // ref: User
  fileName: String,
  fileUrl: String,
  fileType: String,
  uploadDate: Date
}

```

### 🔗 Key API Endpoints

| Method | Endpoint             | Description       |
| ------ | -------------------- | ----------------- |
| POST   | `/api/auth/register` | User registration |
| POST   | `/api/auth/login`    | User login        |
| POST   | `/api/auth/logout`   | User logout       |
| GET    | `/api/auth/me`       | Get current user  |

### ⚖️ Lawyers
| Method | Endpoint              | Description                    |
| ------ | --------------------- | ------------------------------ |
| GET    | `/api/lawyers`        | Get all lawyers (with filters) |
| GET    | `/api/lawyers/:id`    | Get lawyer details             |
| PUT    | `/api/lawyers/:id`    | Update lawyer profile          |
| GET    | `/api/lawyers/search` | Search lawyers                 |


### 📁 Cases
| Method | Endpoint         | Description      |
| ------ | ---------------- | ---------------- |
| POST   | `/api/cases`     | Create new case  |
| GET    | `/api/cases`     | Get user's cases |
| GET    | `/api/cases/:id` | Get case details |
| PUT    | `/api/cases/:id` | Update case      |
| DELETE | `/api/cases/:id` | Delete case      |

### 📄 Documents
| Method | Endpoint                 | Description        |
| ------ | ------------------------ | ------------------ |
| POST   | `/api/documents/upload`  | Upload document    |
| GET    | `/api/documents/:caseId` | Get case documents |
| DELETE | `/api/documents/:id`     | Delete document    |


### 🔒 Security Features
| Feature              | Description                          |
| -------------------- | ------------------------------------ |
| Authentication       | JWT-based tokens with expiration     |
| Authorization        | Role-based access control (RBAC)     |
| Data Validation      | Input sanitization and validation    |
| Password Security    | Bcrypt hashing with salt rounds      |
| File Upload Security | File type validation and size limits |
| CORS                 | Restricted to trusted origins        |
| Rate Limiting        | Prevents API abuse                   |



---

##  Testing & Performance

The system was tested using:

* Unit Testing
* Integration Testing
* System Testing
* User Acceptance Testing

**Performance Highlights:**

* Authentication response < 1 second
* Real-time database updates
* Document upload latency ~1–2 seconds
* AI responses within 2–4 seconds
* Stable performance on low-end Android devices

---

##  Research Publication

**Title:** *Nyaya Connect: Justice Delivered Digitally*
**Journal:** International Journal of Scientific Research in Engineering and Management (IJSREM)
**ISSN:** 2582-3930
**Volume:** 09, Issue 11
**Month & Year:** November 2025

**Authors:**

* Tanishka Jadon
* Vatsal Raina
* Rohan Singh
* Utkarsh Ranjan
* Kavyashree G. M

---

## Repository Note

>  **Note on Repository Structure**

This repository was initialized with the standard Flutter project structure.
The **core implementation and functional modules** were developed and tested locally as part of the academic project and are demonstrated through the working mobile application and documented research paper.

The repository serves as:

* A **project reference**
* An **academic artifact**
* A base for future enhancements and extensions

---

##  Future Enhancements


* Voice-based legal assistance
* Integration with official **e-Court systems**
* Blockchain-based document verification
* Advanced analytics dashboards
* Offline access with smart caching

---





