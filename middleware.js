module.exports = (req, res, next) => {
  // Simulate authentication check
  const publicPaths = ['/api/register', '/api/login'];
  
  if (publicPaths.includes(req.path)) {
    return next();
  }
  
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token && req.path !== '/api/login') {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  // Simple token validation (in production, verify JWT)
  if (token && token.startsWith('valid_token_')) {
    req.user = { id: 1, role: 'admin' }; // Mock user
    return next();
  }
  
  next();
};