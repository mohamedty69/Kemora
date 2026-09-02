SELECT 
    g.Name AS GovName, 
    p.PlaceID, 
    p.Name AS PlaceName, 
    p.Rating, 
    p.MainImageURL
FROM Governorates g
JOIN Places p ON p.GovernorateID = g.GovernorateID
WHERE p.MainImageURL IS NOT NULL AND p.MainImageURL LIKE 'http%'
ORDER BY g.Name, p.Rating DESC, p.Name ASC;
