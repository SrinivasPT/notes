import React from "react";
import { CheckCircle, ClipboardList, Bell, User } from "lucide-react";

// Reusable Button with polished styling
const Button = ({ children, variant = "solid", size = "sm", onClick }) => {
  const base = "inline-flex items-center justify-center font-medium rounded-lg transition-all duration-200";
  const sizes = {
    sm: "px-3 py-1 text-sm",
    md: "px-4 py-2 text-base",
  };
  const variants = {
    solid: "bg-blue-600 text-white hover:bg-blue-700 shadow-sm",
    outline: "border border-gray-300 text-gray-700 bg-white hover:bg-gray-50",
  };
  return (
    <button onClick={onClick} className={`${base} ${sizes[size]} ${variants[variant]}`}>
      {children}
    </button>
  );
};

// StatCard with modern design
const StatCard = ({ icon: Icon, title, value, headerColor }) => {
  return (
    <div className="flex flex-col rounded-xl shadow-md overflow-hidden bg-white hover:shadow-lg transition-shadow">
      <div className={`flex items-center gap-3 px-4 py-3 ${headerColor}`}>
        <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
          <Icon className="w-5 h-5 text-white" />
        </div>
        <div className="text-white font-medium text-sm">{title}</div>
      </div>
      <div className="px-4 py-4">
        <div className="text-3xl font-bold text-gray-900">{value}</div>
        <div className="text-sm text-gray-500 mt-1">
          {title === "Tasks"
            ? "Upcoming Tasks"
            : title === "Approvals"
            ? "Pending Approvals"
            : "New Notifications"}
        </div>
      </div>
    </div>
  );
};

// TaskItem with refined layout
const TaskItem = ({ title, subtitle, description, actions }) => {
  return (
    <div className="flex flex-col rounded-xl bg-white shadow-sm hover:shadow-md transition-shadow p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-base font-semibold text-gray-900">{title}</h3>
          {subtitle && <div className="text-xs text-gray-500 mt-1">{subtitle}</div>}
        </div>
        {actions && <div className="flex items-center gap-2">{actions}</div>}
      </div>
      {description && <p className="text-sm text-gray-700 mt-3 leading-snug">{description}</p>}
    </div>
  );
};

// Main Dashboard
const Dashboard = () => {
  return (
    <div className="max-w-5xl mx-auto p-6 space-y-6 font-sans bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center text-gray-600 shadow-sm">
          <User className="w-5 h-5" />
        </div>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
        <StatCard icon={ClipboardList} title="Tasks" value="5" headerColor="bg-blue-600" />
        <StatCard icon={CheckCircle} title="Approvals" value="2" headerColor="bg-green-500" />
        <StatCard icon={Bell} title="Notifications" value="3" headerColor="bg-purple-500" />
      </div>

      {/* Task list */}
      <div className="space-y-4">
        <TaskItem
          title="Quarterly Budget Report"
          subtitle={<span className="text-xs font-medium">Due Apr 23</span>}
          description="The quarterly budget report is due on April 26. Please review and submit the final report."
          actions={<Button size="sm">Approve</Button>}
        />

        <TaskItem
          title="Vacation Request"
          subtitle={<span className="text-xs font-medium">John Doe has submitted</span>}
          description="John Doe has submitted a vacation request for the period of May 10 to May 14."
          actions={
            <>
              <Button size="sm">Approve</Button>
              <Button size="sm" variant="outline">Reject</Button>
            </>
          }
        />

        <TaskItem
          title="System Maintenance"
          subtitle={<span className="text-xs">Scheduled for Apr 23</span>}
          description="A system maintenance window is scheduled for April 23 between 1:00 AM and 4:00 AM."
        />
      </div>
    </div>
  );
};

export default Dashboard;
