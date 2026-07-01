import os

filepath = r"C:\Users\Amelia\OneDrive\Documents\NetBeansProjects\assessmentvetting\web\vetterDashboard.jsp"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

target = '<div class="stat-grid">'
if "calendarWidget.jsp" not in content and target in content:
    replacement = target + """
    </div>
    <div style="display:flex; flex-wrap:wrap; gap:20px; align-items:flex-start; margin: 0 1.75rem 1.5rem;">
      <div style="flex:1; min-width: 0;">
        <div class="stat-grid" style="padding: 0;">
"""
    # This splits the stat-grid and puts it inside a flex container
    # Let's use a simpler approach. Just put the widget before the stat-grid.
    
    replacement2 = """
    <div style="display:flex; flex-wrap:wrap; gap:20px; padding: 1.5rem 1.75rem 0;">
      <div style="flex:1; min-width: 0;">
""" + target.replace('padding: 1.5rem 1.75rem;', 'padding: 0;')

    # Actually, let's just insert the calendarWidget right before stat-grid
    simple_replacement = """
    <div style="padding: 1.5rem 1.75rem 0;">
        <jsp:include page="calendarWidget.jsp"/>
    </div>
""" + target
    
    content = content.replace(target, simple_replacement)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print("Patched vetterDashboard.jsp")
