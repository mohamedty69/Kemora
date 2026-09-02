UPDATE g
SET ImageURL = p.MainImageURL
FROM Governorates g
CROSS APPLY (
    SELECT TOP 1 MainImageURL
    FROM Places
    WHERE (GovernorateID = g.GovernorateID OR Name LIKE '%' + g.Name + '%' OR Address LIKE '%' + g.Name + '%')
      AND MainImageURL IS NOT NULL 
      AND MainImageURL LIKE 'http%'
    ORDER BY 
      CASE WHEN GovernorateID = g.GovernorateID THEN 0 ELSE 1 END,
      Rating DESC
) p;
