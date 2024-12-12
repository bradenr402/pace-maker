# PaceMaker

![PaceMaker Logo](app/assets/images/logo.svg)

## 📋 Overview

**_PaceMaker_** is a powerful Ruby on Rails web application designed to help cross country runners stay motivated, meet personal running goals, and keep them connected and engaged with their teams. It features a user-friendly interface, detailed team management and user run tracking, goal-setting tools on a per-team basis, and the ability for coaches to track their team's collective progress towards team goals. Coaches can inspire their teams by setting goals. With customizable settings that elevate the experience for both individual runners and teams, PaceMaker helps everyone stay on track and achieve their running objectives while fostering a supportive and competitive team environment.

---

You can find the deployed application at the following link: [pace-maker.onrender.com](https://pace-maker.onrender.com/)

## ⭐ Key Features

- **Authentication & Authorization**: Secure user authentication with Devise, including Google OAuth for easy sign-in.
- **Team Management**: Create, manage, and join teams, with support for join requests, memberships, and team ownership.
- **Run Tracking**: Users can track their runs, view progress, and celebrate streak advancements, fostering motivation and consistency.
- **User Settings**: Comprehensive personalization options for privacy and display settings, with easy one-click reset to defaults.
- **Team Settings**: Team owners can customize team-specific settings, including team goals, season dates, the starting day of the week, and membership requirements - all with easy one-click reset to default settings.
- **Interactive Dashboards**: Use Turbo Frames and Stimulus for a responsive, dynamic experience, featuring visual data representations and progress charts, with caching to optimize performance.
- **Home Page**: A welcoming and encouraging interface featuring:
  - Recent updates, such as team updates, new runs by users you know, team creations, and join requests.
  - Personal statistics like current and record streaks, with motivational messages based on user activity.
- **Advanced Styling**: Tailwind CSS for a modern, aesthetic design that ensures both clarity and consistency.

## 🛠️ Tech Stack

- **Framework**: [Ruby on Rails](https://rubyonrails.org/)
- **Front-End**: [Tailwind CSS](https://tailwindcss.com), [Stimulus](https://stimulus.hotwired.dev/), [Turbo](https://turbo.hotwired.dev/), [Chartkick](https://chartkick.com/)
- **Authentication**: [Devise](https://github.com/heartcombo/devise)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Deployment**:
  - **URL**: [pace-maker.onrender.com](https://pace-maker.onrender.com)
  - **Hosting Provider**: [Render](https://render.com)
  - **Status**: Available

## 🚀 Getting Started

To run PaceMaker on your local machine, follow these steps:

### Prerequisites

- Ruby 3.3.6+
- Rails 7.2+
- PostgreSQL 14.14+

### Installation

1. Open your terminal and navigate to your preferred directory for cloning the project.

2. Clone the repository:

```shell
git clone https://github.com/bradenr402/pace-maker.git
```

3. Change directory to the cloned repository:

```shell
cd pace-maker
```

4. Install dependencies:

```shell
bundle install
```

5. Create the database:

```shell
rails db:create
```

6. Migrate the database:

```shell
rails db:migrate
```

7. Start up the application:

```shell
rails server
```

8. Visit [localhost:3000](https://localhost:3000) in your browser to view the application.

## 🔑 Key Components

### 🔐 Authentication

- **Devise**: A flexible authentication solution for Rails applications, handling user registration, login, and secure password management.
- **Google OAuth**: A secure and user-friendly way to authenticate users through Google accounts.
- **Session Management**: Secure handling of user sessions and authentication tokens.
- **Password Recovery**: Built-in password reset functionality via email.

### 👥 Team Management

- **Teams**: Create and join teams, manage memberships, and customize settings.
- **Join Requests**: Team owners must approve join requests before new members can join.
- **Team Statistics**: Compare your team's progress towards its goals with its progress through the season to see if they're on track to meet their goals.
- **Team Goals**: Team owners can set goals for their team, and members can set their own personal goals.
- **Rankings**: Compare team member rankings across different time periods, including season, month, and week.

### 📊 Run Tracking & Streaks

- **Runs**: Users can track their runs, view progress, and celebrate streak advancements.
- **Streaks**: Users can track their personal running streaks, including their current streak and their longest streak.
- **Run Statistics**: Pace is automatically calculated based on the distance and time of the run.
- **Achievement System**: Badges and rewards for reaching milestones.
- **Progress Visualization**: Charts and graphs showing running progress over time.

### ⚙️ Settings & Preferences

- **User Settings**: Users can customize their settings, including privacy controls and display preferences.
- **Team Settings**: Team owners can set team-specific settings, such as team goals, season dates, the starting day of the week, and join requirements for team members.
- **One-Click Reset**: Easy one-click reset to default settings.

### 📈 Analytics & Insights

- **Team Trends**: Line charts and bar graphs visualizing team performance trends over time.
- **Member Trends**: Line charts and bar graphs showing individual member performance trends over time.
- **Goal Tracking**: Progress bars and milestones for monitoring both personal and team goals.

## 🔮 Future Improvements

- **Notifications**: Implement real-time web push notifications for team updates, join requests, run reminders, and run achievements.
- **Social Features**: Add social networking capabilities, such as the ability to like and comment on runs.
- **Advanced Team Roles**: Introduce different team roles, such as team captains, with tailored permissions.
- **Team Events**: Schedule team events like breaks, rest periods, and training sessions.
- **External Integrations**: Integrate with third-party APIs, such as Strava and Garmin, for automatic data import.
- **Mobile App**: Develop a native mobile app for iOS with offline support.
- **Internationalization (i18n) Support**: Add multi-language support to accomodate a global user base.
- **Gamification and Achievements**: Enhance gamification elements, such as badges, achievements, and leaderboards, to encourage user engagement.

## 🤝 Contributing

1. Fork the repository.
2. Create a new branch for your feature or bug fix.

```shell
git checkout -b feature/your-feature
```

3. Commit your changes.

```shell
git commit -m "feat: add your-feature"
```

4. Push to the branch.

```shell
git push origin feature/your-feature
```

5. Open a pull request.

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/license/mit/). Feel free to use, modify, and distribute the code.

## 📧 Contact

For any questions or inquiries, feel free to send an email to [get.pace.maker@gmail.com](mailto:get.pace.maker@gmail.com), or open an issue in the GitHub repository.
