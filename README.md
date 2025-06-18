# 💬 Echo - A Social Communication Platform

> **Echo is a GUI-based Flutter social application meticulously engineered as my 4th semester Data Structures and Algorithms (DSA) project.**

## 🎯 **Project Goal**

The primary objective of the Echo project was to **gain a strong practical understanding of how to implement and integrate fundamental Data Structures and Algorithms (DSA) in a real-world, interactive application.** This project serves as a comprehensive demonstration of how DSA concepts are crucial for building scalable, efficient, and feature-rich systems in software development. Through a **robust and object-oriented design**, Echo also emphasizes how a well-structured project can **facilitate easy implementation of new features and future scalability.**

## ℹ️ **About the Application**

Echo provides a rich set of social features designed to mimic modern social networking interactions. It offers robust one-to-one chat capabilities, a dynamic news feed, comprehensive friend request management, and intelligent friend suggestions. All these functionalities are powered by an extensive implementation and integration of core data structures and algorithms, showcasing their practical application within a user-friendly and interactive GUI.

## 🌟 **Key Highlights**

* **Deep DSA Integration**: A practical demonstration of how core data structures and algorithms form the backbone of modern social applications, designed from a low-level system design perspective.

* **Robust & Modular Design**: Built with a focus on **Object-Oriented Programming (OOP) principles** and a clear MVC architecture, ensuring the project is highly maintainable, extensible, and allows for **easy implementation of new features**.

* **User-Centric Features**: Efficient user registration, authentication, and profile management for a seamless user experience.

* **Dynamic Social Interaction**: Features for posting, message exchange, and managing friend connections to foster community.

* **Smart Social Features**: Friend suggestions powered by graph algorithms, and a news feed optimized for relevance and timely content delivery.

## 🚀 **Core Features**

### 👥 **User Management & Profile**

* **User Registration & Login**: Secure authentication for new and existing users.

* **User Profiles**: Manage personal information and display posts.

### 💬 **Communication & Interaction**

* **One-to-One Chat**: Exchange messages between friends using a responsive messaging interface.

* **Friend Requests**: Send, accept, or decline connection requests.

* **Friend Connections**: Establish and manage connections between users (adding/accepting friendships).

* **News Feed**: A dynamic feed displaying posts from connected friends.

* **Notifications**: In-app alerts for new messages, friend requests, and accepted connections.

* **Posting**: Create and share image-based posts with captions.

### 🧠 **Smart Social Features**

* **Friend Suggestions**: Discover potential connections based on your existing friend network.

* **Dynamic News Feed**: Posts are organized to show the most recent and relevant content first.

## 📚 **Educational Purpose**

This project was developed with a strong focus on applying theoretical Data Structures and Algorithms concepts to a practical, full-stack application. It aims to demonstrate:

* The **real-world utility** and performance implications of various data structures.

* **System design principles** for building complex applications using DSA as core components.

* The process of **integrating custom DSA implementations** with a modern framework (Flutter) and backend (Firebase).

* Best practices in **Object-Oriented Programming (OOP)** and architectural patterns like **MVC**.

## 📊 **Data Structures & Algorithms in Action**

This project is a direct application of various data structures and algorithms to solve real-world social network challenges:

| Data Structure / Algorithm | Application |
| :------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **AVL Tree** | Implemented for efficient **user management** and **lookup**. User profiles are stored in the AVL Tree, allowing for quick `O(log N)` search, insertion, and retrieval operations by username, ensuring scalability for a growing user base. |
| **Graph (Adjacency Matrix) & BFS**| A dynamically sized **List of Lists (Adjacency Matrix)** represents the entire **friend network**. This graph is used to manage and establish friendships and, critically, to implement **friend suggestions** using a **Breadth-First Search (BFS)** algorithm. BFS efficiently finds "friends of friends" (level 2 connections) to suggest new connections. |
| **Linked List** | **Chat History**: `MessageNode`s form a Linked List to store individual messages within each one-to-one conversation. <br/> **Chat List**: `ChatNode`s form a Linked List to efficiently manage and access all active conversations for a user. <br/> **Internal Structures**: Also used internally for `PostStack`, `NotificationStack`, and `RequestQueue` nodes. |
| **Stack (LIFO)** | **User Posts**: `PostStack` maintains a user's recent posts in a Last-In, First-Out manner. <br/> **Notifications**: `NotificationStack` manages in-app notifications, ensuring new alerts are readily accessible. |
| **Queue (FIFO)** | `RequestQueue` manages incoming **friend requests** in a First-In, First-Out (FIFO) order, ensuring requests are processed equitably based on arrival time. |
| **Heap (Priority Queue)** | `NewsFeedHeap` is implemented as a **Max-Heap** (ordered by date) to manage the **news feed**. This allows the application to efficiently retrieve and display posts from friends in chronological order (newest first). |

## 💻 **Tech Stack**

Echo is built using the following core technologies and architectural patterns:

* **Frontend**: Flutter (Dart) for a cross-platform GUI, utilizing GetX for state management.
* **Backend & Persistence**: Firebase Firestore for scalable data storage and user authentication.
* **Core Data Structures**: Custom-built implementations of various ADTs including **AVL Tree**, **Graph (Adjacency Matrix)**, **Linked List**, **Stack**, **Queue**, and **Heap (Priority Queue)**, which are central to the application's logic and performance.

### 📂 **Project Structure**
